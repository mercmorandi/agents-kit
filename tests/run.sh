#!/usr/bin/env bash
# agents-kit test suite. Renders every fixture in tests/fixtures/ into a
# temporary repo and checks the result; then checks the kit's own behaviour.
#
#   tests/run.sh            run everything
#   tests/run.sh -v         also print the commands of failing checks
#
# External validators are used when installed and skipped otherwise:
# docker (compose config), actionlint (workflows), hadolint (Dockerfiles),
# shellcheck (init.sh). The kit's CI installs all four.
set -uo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INIT="$KIT/init.sh"
VERBOSE=0; [ "${1:-}" = "-v" ] && VERBOSE=1
PASS=0; FAIL=0; SKIP=0
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

ok()   { PASS=$((PASS + 1)); echo "  ok    $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  FAIL  $1"; [ "$VERBOSE" -eq 1 ] && [ -n "${2:-}" ] && echo "$2" | sed 's/^/        /'; }
skip() { SKIP=$((SKIP + 1)); echo "  skip  $1"; }
have() { command -v "$1" >/dev/null 2>&1; }
have_docker() { have docker && docker info >/dev/null 2>&1; }
# linters: the binary when installed, otherwise the official image through docker
run_hadolint() { if have hadolint; then hadolint "$@"; else docker run --rm -i hadolint/hadolint hadolint "${@:1:$#-1}" - < "${@: -1}"; fi; }
run_actionlint() { if have actionlint; then actionlint "$@"; else docker run --rm -v "$(dirname "$1"):/wf:ro" rhysd/actionlint:latest -color "/wf/$(basename "$1")"; fi; }

# check NAME COMMAND... — pass when the command exits 0
check() { local name="$1"; shift; local out; if out="$("$@" 2>&1)"; then ok "$name"; else fail "$name" "$out"; fi; }

echo "agents-kit tests — $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo
echo "— Kit"
check "init.sh has valid syntax" bash -n "$INIT"
check "init.sh --help exits 0" "$INIT" --help
check "init.sh --check on the kit: no broken links" "$INIT" --check
if have shellcheck; then check "shellcheck init.sh" shellcheck -S warning "$INIT"; else skip "shellcheck (not installed)"; fi
check "templates contain no unmatched IF/ENDIF" bash -c '
  for f in $(find "'"$KIT"'/templates" "'"$KIT"'/.agents" "'"$KIT"'/CLAUDE.md.template" -type f); do
    i=$(grep -cE "\{\{IF [A-Z_]+\}\}" "$f"); e=$(grep -c "{{ENDIF}}" "$f")
    [ "$i" -eq "$e" ] || { echo "$f: $i IF vs $e ENDIF"; exit 1; }
  done'

for fx in "$KIT"/tests/fixtures/*.answers; do
  name="$(basename "$fx" .answers)"
  repo="$WORK/$name"; mkdir -p "$repo"
  expect_left="$(sed -n 's/^# expect-left: *//p' "$fx")"
  echo; echo "— Fixture $name"

  check "copy" "$INIT" "$repo"
  check "configure from answers" "$INIT" "$repo" --answers "$fx"
  check "no conditional markers left" bash -c '! grep -rlE "\{\{(IF [A-Z_]+|ENDIF)\}\}" "'"$repo"'" --exclude-dir=.git | grep -v _TEMPLATE'
  check "no gate placeholders left" bash -c '! grep -rlE "\{\{(PROJECT_|FE_DIR|BE_DIR|BE_LANGUAGE|DATABASE|REDIS|CI)\}\}" "'"$repo"'" --exclude-dir=.git | grep -v _TEMPLATE'
  left="$("$INIT" "$repo" --check | grep -oE '\{\{[A-Z_]+\}\}' | tr -d '{}' | sort -u | tr '\n' ' ' | sed 's/ $//')"
  want="$(echo "$expect_left" | tr ' ' '\n' | sort -u | tr '\n' ' ' | sed 's/ $//')"
  if [ "$left" = "$want" ]; then ok "placeholders left = expected [${want:-none}]"; else fail "placeholders left = expected" "left: [$left] want: [$want]"; fi
  check "--check exits 0 (no broken links)" "$INIT" "$repo" --check
  check "saved answers carry no placeholder" bash -c '! grep -q "{{" "'"$repo"'/.agents/.kit-answers"'

  # Makefile
  check "make lists targets" bash -c 'cd "'"$repo"'" && make >/dev/null'
  for t in install lint typecheck test build up down logs; do
    check "make -n $t" bash -c 'cd "'"$repo"'" && make -n '"$t"' >/dev/null'
  done
  check "make -n test-file FILE=x runs one file" bash -c 'cd "'"$repo"'" && make -n test-file FILE=x | grep -q " x$"'
  check "make test-file without FILE fails with usage" bash -c 'cd "'"$repo"'" && ! make test-file >/dev/null 2>&1'
  if grep -q '^BE_DIR' "$repo/Makefile"; then check "make -n install-backend" bash -c 'cd "'"$repo"'" && make -n install-backend >/dev/null'; fi
  if grep -q '^FE_DIR' "$repo/Makefile"; then check "make -n install-frontend" bash -c 'cd "'"$repo"'" && make -n install-frontend >/dev/null'; fi

  # compose
  if have docker && docker compose version >/dev/null 2>&1; then
    check "docker compose config" bash -c 'cd "'"$repo"'" && docker compose config --quiet'
  else skip "docker compose config (docker not available)"; fi

  # Dockerfiles: every build context has a .dockerignore, every Dockerfile lints
  while IFS= read -r df; do
    rel="${df#$repo/}"
    if have hadolint || have_docker; then check "hadolint $rel" run_hadolint --ignore DL3018 --ignore DL3013 --ignore DL3008 "$df"; else skip "hadolint $rel (neither hadolint nor docker)"; fi
    check "$rel runs as non-root" grep -q '^USER ' "$df"
    check "$rel has a HEALTHCHECK" grep -q '^HEALTHCHECK' "$df"
  done < <(find "$repo" -name Dockerfile -not -path '*/.git/*')
  check "every compose build context has a .dockerignore" bash -c '
    cd "'"$repo"'" && for ctx in $(grep -E "^\s+context:" docker-compose.yml | awk "{print \$2}" | sort -u); do
      [ -f "$ctx/.dockerignore" ] || { echo "missing $ctx/.dockerignore"; exit 1; }; done'

  # CI workflow
  if [ -f "$repo/.github/workflows/ci.yml" ]; then
    if have actionlint || have_docker; then check "actionlint ci.yml" run_actionlint "$repo/.github/workflows/ci.yml"; else skip "actionlint (neither actionlint nor docker)"; fi
    check "ci.yml uses only make targets that exist" bash -c '
      cd "'"$repo"'" && for t in $(grep -oE "make [a-z-]+" .github/workflows/ci.yml | awk "{print \$2}" | sort -u); do
        make -n "$t" >/dev/null 2>&1 || { echo "ci.yml calls make $t, Makefile has no such target"; exit 1; }; done'
  else
    if grep -q '^CI=yes' "$fx"; then fail "ci.yml expected but missing"; else ok "no ci.yml (CI=no)"; fi
  fi

  # idempotency: a second run changes nothing
  snap="$WORK/$name.snap"; cp -R "$repo" "$snap"
  check "second configure: everything skipped" bash -c '"'"$INIT"'" "'"$repo"'" --answers "'"$fx"'" | grep -E "^  (copy|render) " && exit 1 || exit 0'
  check "second configure: no file changed" diff -r "$repo" "$snap"
done

echo; echo "— Behaviour"
r="$WORK/behaviour"; mkdir -p "$r"
echo MINE > "$r/CLAUDE.md"
check "copy never overwrites an existing CLAUDE.md" bash -c '"'"$INIT"'" "'"$r"'" >/dev/null && [ "$(cat "'"$r"'/CLAUDE.md")" = MINE ]'
check "--no-claude-md leaves the root alone" bash -c 'd="'"$WORK"'/noclaude"; mkdir -p "$d" && "'"$INIT"'" "$d" --no-claude-md >/dev/null && [ ! -e "$d/CLAUDE.md" ]'
check "configure without CLAUDE.md works" bash -c 'd="'"$WORK"'/noclaude"; yes "" | head -80 | "'"$INIT"'" "$d" --configure >/dev/null'
check "interactive configure: gates are not asked twice" bash -c '
  d="'"$WORK"'/interactive"; mkdir -p "$d" && "'"$INIT"'" "$d" >/dev/null
  out="$(yes "" | head -80 | "'"$INIT"'" "$d" --configure 2>&1)"
  echo "$out" | sed -n "/— Values/,\$p" | grep -qE "Project shape|Backend language|Frontend folder" && exit 1 || exit 0'
check "interactive configure: project name defaults to the folder name" bash -c '
  d="'"$WORK"'/interactive"; grep -q "^PROJECT_NAME=interactive$" "$d/.agents/.kit-answers"'
check "numeric values reject text" bash -c '
  d="'"$WORK"'/numeric"; mkdir -p "$d" && "'"$INIT"'" "$d" >/dev/null
  out="$(yes "" | head -80 | sed "15s/.*/abc/" | "'"$INIT"'" "$d" --configure 2>&1)"
  echo "$out" | grep -q "please enter a whole number" && grep -q "^COMMIT_TITLE_MAX=50$" "$d/.agents/.kit-answers"'
check "enum values reject unknown answers" bash -c '
  d="'"$WORK"'/enum"; mkdir -p "$d" && "'"$INIT"'" "$d" >/dev/null
  out="$(yes "" | head -80 | sed "2s/.*/mobile/" | "'"$INIT"'" "$d" --configure 2>&1)"
  echo "$out" | grep -q "please answer one of"'
check "--answers without a terminal leaves missing values, does not hang" bash -c '
  d="'"$WORK"'/answers-notty"; mkdir -p "$d" && "'"$INIT"'" "$d" >/dev/null
  grep -v "^CANONICAL_" "'"$KIT"'/tests/fixtures/backend-python-pip-none.answers" > "$d/partial.answers"
  out="$("'"$INIT"'" "$d" --answers "$d/partial.answers" < /dev/null 2>&1)"
  echo "$out" | grep -q "leave  CANONICAL_ENTITY" && ! grep -q "^CANONICAL_ENTITY=" "$d/.agents/.kit-answers"'
check "no healthcheck uses localhost (IPv6 vs IPv4 inside Alpine)" bash -c '! grep -rn "HEALTHCHECK.*localhost\|CMD-SHELL.*localhost" "'"$KIT"'/templates"'
check "no template uses pnpm@latest" bash -c '! grep -rn "pnpm@latest" "'"$KIT"'/templates"'
check "--check fails on a broken link" bash -c '
  d="'"$WORK"'/broken"; mkdir -p "$d" && "'"$INIT"'" "$d" >/dev/null
  printf "# x\n\n[plan](nope/PLAN.md)\n" > "$d/.agents/plans/broken.md"
  ! "'"$INIT"'" "$d" --check >/dev/null'
check "a real placeholder is never written inside backticks" bash -c '
  ! grep -rnoE "\`[^\`]*\{\{[A-Z][A-Z_]+\}\}[^\`]*\`" "'"$KIT"'/.agents" "'"$KIT"'/CLAUDE.md.template" "'"$KIT"'/templates" \
    | grep -v "_TEMPLATE" | grep -v "/README.md:" | grep -v "workflow/README.md"'

echo
echo "Results: $PASS passed, $FAIL failed, $SKIP skipped"
[ "$FAIL" -eq 0 ]
