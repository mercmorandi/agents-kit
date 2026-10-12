#!/usr/bin/env bash
# agents-kit — copy the .agents/ kit into a repository, configure it, check it.
# Run `init.sh --help` for the full manual.
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPL="$KIT_DIR/templates"
VERSION="0.1.0"

usage() {
  cat <<'HELP'
agents-kit — a project-agnostic .agents/ folder, Makefile, Docker and CI
scaffold for repositories built with coding agents (Claude Code).

USAGE
  init.sh <repo>                     copy .agents/ and CLAUDE.md into <repo>; never overwrites
  init.sh <repo> --no-claude-md      same, but leave the repo root alone (no CLAUDE.md)
  init.sh <repo> --configure         answer the questions, render Makefile / Docker / CI, fill placeholders
  init.sh <repo> --answers <file>    same, taking answers from a saved file; only missing ones are asked
  init.sh <repo> --check             list what is still open; exit 1 on broken links
  init.sh --check                    check the kit itself
  init.sh --help                     this manual
  init.sh --version                  print the version

TYPICAL FLOW
  init.sh .              copy (existing files are reported as "skip")
  init.sh . --configure  answer the questions once
  init.sh . --check      what is left are TODO(project) sections: canonical files
                         and project facts you write once the codebase exists

HOW --configure WORKS
  Phase 1 — shape. A few gate questions decide what the project is:
    PROJECT_SHAPE        frontend | backend | fullstack   (fullstack = both sides in one repo:
                                                          a pnpm workspace when both are Node,
                                                          two self-contained apps otherwise)
    BE_LANGUAGE          typescript | python              (backend only)
    FE_DIR / BE_DIR      where each side lives            (fullstack: client / server; else .)
    FE_PACKAGE_MANAGER   pnpm | npm
    BE_PACKAGE_MANAGER   pnpm (typescript) | pip | uv | poetry (python)
    DATABASE             postgres | mongo | none          (local compose service + CI service)
    REDIS                yes | no
    CI                   yes | no                         (GitHub Actions: lint, typecheck, tests, docker build)
  Phase 2 — render. Conditional blocks ({{IF X}} … {{ENDIF}}) in CLAUDE.md and
  .agents/ are resolved, and these files are created (never overwritten):
    Makefile               the single entry point: make lint / build / test / test-file FILE=… / up / logs-backend …
    docker-compose.yml     local stack: your sides + database + redis as chosen
    .dockerignore
    <FE_DIR>/Dockerfile    Next.js standalone, multi-stage, non-root
    <BE_DIR>/Dockerfile    Node (pnpm deploy, non-root) or Python (venv, non-root)
    .github/workflows/ci.yml   PR checks through make targets, per side, docker build   (CI=yes)
  Phase 3 — values. Every remaining {{PLACEHOLDER}} is asked once, in a fixed
  order, then replaced everywhere it appears. The questions you see depend on
  the shape: FE_* only with a frontend, BE_* only with a backend, branches
  only with CI.
    Enter            accept the suggested value shown in [brackets]
    Enter, no [..]   the question has no default: the placeholder is left as is
    -                leave the placeholder for later, ignoring the suggestion
  Answers are saved to .agents/.kit-answers. Re-running --configure asks only
  for what is still open. Pass that file to another repo with --answers: values
  it contains are applied silently, missing ones are asked when a terminal is
  attached and left for later when there is none (CI, pipes).
  Placeholders written inside `backticks` are treated as quoted documentation
  and are neither asked nor replaced.

THE VALUES
  Working rules (.agents/workflow/)
    CHAT_LANGUAGE       language of replies to the human               e.g. Italian
    CODE_LANGUAGE       code, comments, commits, dev docs              e.g. English
    DOC_LANGUAGE        plan and milestone documents                   e.g. English
    AGENT_COMMITS       who runs `git commit`:
                          never       the agent hands over files + a suggested message; you commit
                          on request  the agent commits only when told to
                          always      the agent commits each verified milestone on its branch
                        (push, PRs and the remote are governed by GIT_REMOTE_POLICY, not here)
    COMMIT_TITLE_MAX    hard max length of a commit title              e.g. 50
    MILESTONE_CADENCE   stop after each milestone | chain until told
    GIT_REMOTE_POLICY   what the agent may do with the git remote      e.g. never fetch, pull or push
    ENVIRONMENTS        named environments and which one the agent may touch
    PLAN_DATES_POLICY   whether plan documents carry dates
  Project facts (CLAUDE.md, Makefile, Docker, CI)
    PROJECT_NAME        compose project name, image names               default: repo folder name
    AUTH                auth provider named in CLAUDE.md
    NODE_VERSION / PNPM_VERSION / PYTHON_VERSION                        e.g. 22 / 10.13.1 / 3.12
    FE_STACK FE_PORT FE_PACKAGE_NAME(monorepo) FE_INSTALL_CMD FE_DEV_CMD FE_LINT_CMD FE_FORMAT_CMD
    FE_TYPECHECK_CMD FE_TEST_CMD FE_TEST_SINGLE_CMD FE_BUILD_CMD
    BE_FRAMEWORK BE_PORT BE_PACKAGE_NAME(monorepo) BE_ENTRYPOINT(node) BE_ASGI_APP(python)
    BE_INSTALL_CMD BE_DEV_CMD BE_LINT_CMD BE_FORMAT_CMD BE_TYPECHECK_CMD BE_TEST_CMD BE_TEST_SINGLE_CMD
    BE_BUILD_CMD BE_MIGRATE_CMD(python)
    INSTALL_CMD         what `make install` runs at the repo root
    MAIN_BRANCH DEV_BRANCH                                              CI
    EXTERNAL_ID_NAME PAGE_DEFAULT_LIMIT PAGE_MAX_LIMIT                   API rules
    CANONICAL_ENTITY CANONICAL_RESOURCE   files to copy for the hexagonal patterns (- if none yet)

FILES
  CLAUDE.md             entry point the agent reads first; routes into .agents/ and the Makefile
  .agents/workflow/     how the agent works (project-agnostic)
  .agents/rules/        what holds in this project (baselines to edit)
  .agents/patterns/     recipes to copy, one canonical example each
  .agents/plans/        feature plans + PROGRESS / HANDOFF / KICKOFF / MILESTONES templates
  .agents/skills/       on-demand reference; exposed via .claude/skills/<name> symlinks
  .agents/.kit-answers  your answers, reusable with --answers
  .agents/.kit-files    the infra files this kit rendered, so --check and --configure find them

Bash 3.2 compatible. No rm, no overwrite, no git.
HELP
  exit "${1:-0}"
}

# ------------------------------------------------------------------ args ----
TARGET=""; WITH_CLAUDE=1; CHECK=0; CONFIGURE=0; ANSWERS=""
expect_answers=0
for arg in "$@"; do
  if [ "$expect_answers" -eq 1 ]; then ANSWERS="$arg"; expect_answers=0; continue; fi
  case "$arg" in
    --no-claude-md) WITH_CLAUDE=0 ;;
    --with-claude-md) WITH_CLAUDE=1 ;;
    --check) CHECK=1 ;;
    --configure) CONFIGURE=1 ;;
    --answers) CONFIGURE=1; expect_answers=1 ;;
    -h|--help) usage 0 ;;
    --version) echo "agents-kit $VERSION"; exit 0 ;;
    -*) echo "unknown option: $arg" >&2; usage 1 ;;
    *) TARGET="$arg" ;;
  esac
done
[ "$expect_answers" -eq 0 ] || { echo "--answers needs a file" >&2; usage 1; }

# --------------------------------------------------------------- helpers ----
# All files that may hold placeholders in a target: .agents docs (templates
# excluded), CLAUDE.md, and the infra files recorded in .agents/.kit-files.
kit_files() {
  local root="$1" f
  find "$root/.agents" -name '*.md' -not -path '*_TEMPLATE*' -print0 2>/dev/null
  if [ -f "$root/CLAUDE.md" ]; then printf '%s\0' "$root/CLAUDE.md"; fi
  if [ -f "$root/.agents/.kit-files" ]; then
    while IFS= read -r f; do
      [ -n "$f" ] && [ -f "$root/$f" ] && printf '%s\0' "$root/$f"
    done < "$root/.agents/.kit-files"
  fi
  return 0
}

sed_escape() { printf '%s' "$1" | sed -e 's/[\\|&]/\\&/g'; }

# Resolve {{IF COND}} … {{ENDIF}} blocks. $1 = file, $2 = space-separated true conditions.
# Marker lines are removed; false blocks are dropped; runs of blank lines are squeezed.
strip_conditionals() {
  local f="$1" conds=" $2 "
  grep -qE '\{\{(IF [A-Z_]+|ENDIF)\}\}' "$f" || return 0
  awk -v conds="$conds" '
    function truth(c) { return index(conds, " " c " ") > 0 }
    match($0, /\{\{IF [A-Z_]+\}\}/) {
      c = substr($0, RSTART + 5, RLENGTH - 7); depth++
      off[depth] = (skip > 0 || !truth(c)) ? 1 : 0
      if (off[depth]) skip++
      next
    }
    /\{\{ENDIF\}\}/ { if (off[depth]) skip--; depth--; next }
    skip == 0 { print }
  ' "$f" | cat -s > "$f.kit.tmp" && mv "$f.kit.tmp" "$f"
}

# ----------------------------------------------------------------- check ----
check() {
  local root="$1" broken=0 placeholders=0 f
  echo "Checking $root"
  while IFS= read -r -d '' f; do
    local hits
    hits="$(sed -E 's/`[^`]*`//g' "$f" | grep -nE '\{\{[A-Za-z_-]+\}\}|TODO\(project\)' || true)"
    if [ -n "$hits" ]; then
      while IFS= read -r line; do
        echo "  placeholder  ${f#$root/}:${line%%:*}: $(echo "${line#*:}" | grep -oE '\{\{[A-Za-z_-]+\}\}|TODO\(project\)' | head -1)"
        placeholders=$((placeholders + 1))
      done <<< "$hits"
    fi
    case "$f" in *.md) ;; *) continue ;; esac
    local dir link target
    dir="$(dirname "$f")"
    while IFS= read -r link; do
      [ -z "$link" ] && continue
      case "$link" in http://*|https://*|mailto:*|\#*) continue ;; esac
      case "$link" in *…*|*\{\{*|*\<*) continue ;; esac
      target="${link%%#*}"
      [ -z "$target" ] && continue
      if [ ! -e "$dir/$target" ]; then
        echo "  BROKEN LINK  ${f#$root/}: $link"; broken=$((broken + 1))
      fi
    done < <(grep -oE '\]\([^)]+\)' "$f" | sed -E 's/^\]\(//; s/\)$//' || true)
  done < <(kit_files "$root")
  echo "  $placeholders placeholder(s) to fill, $broken broken link(s)"
  [ "$broken" -eq 0 ]
}

if [ "$CHECK" -eq 1 ]; then
  if [ -z "$TARGET" ]; then
    # the kit itself: CLAUDE.md.template stands in for CLAUDE.md
    tmp="$(mktemp -d)"; mkdir -p "$tmp/.agents"; cp -R "$KIT_DIR/.agents/." "$tmp/.agents/"; cp "$KIT_DIR/CLAUDE.md.template" "$tmp/CLAUDE.md"
    check "$tmp" || { rm -rf "$tmp"; exit 1; }
    rm -rf "$tmp"
  else
    [ -d "$TARGET" ] || { echo "not a directory: $TARGET" >&2; exit 1; }
    check "$(cd "$TARGET" && pwd)"
  fi
  exit $?
fi

# ------------------------------------------------------------- configure ----
# Gate questions (phase 1) and their allowed values.
GATES="PROJECT_NAME PROJECT_SHAPE FE_DIR FE_PACKAGE_MANAGER BE_LANGUAGE BE_DIR BE_PACKAGE_MANAGER DATABASE REDIS CI"
# Value questions (phase 3), asked in this order when present.
KNOWN_ORDER="CHAT_LANGUAGE CODE_LANGUAGE DOC_LANGUAGE \
AGENT_COMMITS COMMIT_TITLE_MAX MILESTONE_CADENCE GIT_REMOTE_POLICY ENVIRONMENTS PLAN_DATES_POLICY \
AUTH NODE_VERSION PNPM_VERSION PYTHON_VERSION FE_PACKAGE_NAME BE_PACKAGE_NAME INSTALL_CMD FE_INSTALL_CMD BE_INSTALL_CMD \
FE_STACK FE_PORT FE_DEV_CMD FE_LINT_CMD FE_FORMAT_CMD FE_TYPECHECK_CMD FE_TEST_CMD FE_TEST_SINGLE_CMD FE_BUILD_CMD \
BE_FRAMEWORK BE_PORT BE_ENTRYPOINT BE_ASGI_APP BE_DEV_CMD BE_LINT_CMD BE_FORMAT_CMD BE_TYPECHECK_CMD BE_TEST_CMD BE_TEST_SINGLE_CMD BE_BUILD_CMD BE_MIGRATE_CMD \
MAIN_BRANCH DEV_BRANCH \
EXTERNAL_ID_NAME PAGE_DEFAULT_LIMIT PAGE_MAX_LIMIT CANONICAL_ENTITY CANONICAL_RESOURCE"

# gate values, set by phase 1 (globals so describe() can pick defaults)
G_PROJECT_NAME=""; G_PROJECT_SHAPE=""; G_FE_DIR=""; G_FE_PACKAGE_MANAGER=""; G_BE_LANGUAGE=""; G_BE_DIR=""; G_BE_PACKAGE_MANAGER=""; G_DATABASE=""; G_REDIS=""; G_CI=""

# "description|suggested default|allowed values (space separated, empty = free text)"
describe() {
  local pm="$G_BE_PACKAGE_MANAGER" fepm="$G_FE_PACKAGE_MANAGER"
  local fe_run="pnpm"; [ "$fepm" = "npm" ] && fe_run="npm run"
  local fe_x="pnpm exec"; [ "$fepm" = "npm" ] && fe_x="npx"
  local py_run="uv run"; [ "$pm" = "poetry" ] && py_run="poetry run"; [ "$pm" = "pip" ] && py_run=""
  case "$1" in
    # gates
    PROJECT_NAME)       echo "Project name (compose project, image names)|$(basename "${ROOT:-project}")|" ;;
    PROJECT_SHAPE)      echo "Project shape|fullstack|frontend backend fullstack" ;;
    FE_DIR)             if [ "$G_PROJECT_SHAPE" = fullstack ]; then echo "Frontend folder|client|"; else echo "Frontend folder|.|"; fi ;;
    FE_PACKAGE_MANAGER) echo "Frontend package manager|pnpm|pnpm npm" ;;
    BE_LANGUAGE)        echo "Backend language|typescript|typescript python" ;;
    BE_DIR)             if [ "$G_PROJECT_SHAPE" = fullstack ]; then echo "Backend folder|server|"; else echo "Backend folder|.|"; fi ;;
    BE_PACKAGE_MANAGER) if [ "$G_BE_LANGUAGE" = python ]; then echo "Backend package manager|uv|pip uv poetry"; else echo "Backend package manager|pnpm|pnpm"; fi ;;
    DATABASE)           echo "Database (local compose + CI service)|postgres|postgres mongo none" ;;
    REDIS)              echo "Redis in the local stack|no|yes no" ;;
    CI)                 echo "GitHub Actions CI (lint, typecheck, tests, docker build on pull requests)|yes|yes no" ;;
    # working rules
    CHAT_LANGUAGE)      echo "Language of replies to the human|English|" ;;
    CODE_LANGUAGE)      echo "Language of code, comments, commits, dev docs|English|" ;;
    DOC_LANGUAGE)       echo "Language of plan and milestone documents|English|" ;;
    AGENT_COMMITS)      echo "Commit ownership: never / on request / always|never|never 'on request' always" ;;
    COMMIT_TITLE_MAX)   echo "Hard max length of a commit title|50|" ;;
    MILESTONE_CADENCE)  echo "stop after each milestone / chain until told|stop after each milestone|" ;;
    GIT_REMOTE_POLICY)  echo "What the agent may do with the git remote|never fetch, pull or push; the owner does|" ;;
    ENVIRONMENTS)       echo "Named environments and which one the agent may touch|local only; any shared environment on explicit instruction|" ;;
    PLAN_DATES_POLICY)  echo "Dates in plan documents|no dates; the version history carries the when|" ;;
    # project facts
    AUTH)               echo "Auth provider (or '-')||" ;;
    NODE_VERSION)       echo "Node version|22|" ;;
    PNPM_VERSION)       echo "pnpm version (pinned in Dockerfiles and CI; never 'latest')|$(command -v pnpm >/dev/null 2>&1 && pnpm --version 2>/dev/null || echo 10)|" ;;
    PYTHON_VERSION)     echo "Python version|3.12|" ;;
    FE_INSTALL_CMD)     if [ "$G_PROJECT_SHAPE" = fullstack ] && [ "$G_BE_LANGUAGE" = typescript ] && [ "$fepm" = pnpm ]; then echo "Frontend install command (run inside $G_FE_DIR)|pnpm install --filter \"$(recorded FE_PACKAGE_NAME)...\"|"; else echo "Frontend install command|$fe_run install|"; fi ;;
    BE_INSTALL_CMD)     if [ "$G_BE_LANGUAGE" = python ]; then case "$pm" in uv) echo "Backend install command|uv sync|";; poetry) echo "Backend install command|poetry install|";; *) echo "Backend install command|pip install -r requirements.txt -r requirements-dev.txt|";; esac
                        elif [ "$G_PROJECT_SHAPE" = fullstack ]; then echo "Backend install command (run inside $G_BE_DIR)|pnpm install --filter \"$(recorded BE_PACKAGE_NAME)...\"|"; else echo "Backend install command|pnpm install|"; fi ;;
    INSTALL_CMD)        if [ "$G_PROJECT_SHAPE" = backend ] && [ "$G_BE_LANGUAGE" = python ]; then
                          case "$pm" in uv) echo "Install command (repo root)|uv sync|";; poetry) echo "Install command (repo root)|poetry install|";; *) echo "Install command (repo root)|pip install -r requirements.txt -r requirements-dev.txt|";; esac
                        elif [ "$G_PROJECT_SHAPE" = fullstack ] && [ "$G_BE_LANGUAGE" != typescript ]; then echo "Install command (repo root; each side installs in its own folder)|\$(MAKE) install-frontend install-backend|"
                        else echo "Install command (repo root)|$fe_run install|"; fi ;;
    FE_STACK)           echo "Frontend stack|Next.js|" ;;
    FE_PORT)            echo "Frontend port|3000|" ;;
    FE_PACKAGE_NAME)    echo "Frontend workspace package name (pnpm --filter, root workspace)|@$G_PROJECT_NAME/$(basename "$G_FE_DIR")|" ;;
    FE_DEV_CMD)         echo "Frontend dev command|$fe_run dev|" ;;
    FE_LINT_CMD)        echo "Frontend lint command|$fe_run lint|" ;;
    FE_FORMAT_CMD)      echo "Frontend format command|$fe_x prettier --write .|" ;;
    FE_TYPECHECK_CMD)   echo "Frontend typecheck command|$fe_x tsc --noEmit|" ;;
    FE_TEST_CMD)        echo "Frontend test command|$fe_run test|" ;;
    FE_TEST_SINGLE_CMD) echo "Frontend single test file command (path appended)|$fe_x vitest run|" ;;
    FE_BUILD_CMD)       echo "Frontend build command|$fe_run build|" ;;
    BE_FRAMEWORK)       if [ "$G_BE_LANGUAGE" = python ]; then echo "Backend framework|FastAPI|"; else echo "Backend framework|Express|"; fi ;;
    BE_PORT)            if [ "$G_BE_LANGUAGE" = python ]; then echo "Backend port|8000|"; else echo "Backend port|4000|"; fi ;;
    BE_PACKAGE_NAME)    echo "Backend workspace package name (pnpm --filter)|@$G_PROJECT_NAME/$(basename "$G_BE_DIR")|" ;;
    BE_ENTRYPOINT)      echo "Compiled backend entrypoint (node)|dist/server.js|" ;;
    BE_ASGI_APP)        echo "ASGI app for uvicorn|src.api.main:app|" ;;
    BE_DEV_CMD)         if [ "$G_BE_LANGUAGE" = python ]; then echo "Backend dev command|${py_run:+$py_run }uvicorn src.api.main:app --reload --port 8000|"; else echo "Backend dev command|pnpm dev|"; fi ;;
    BE_LINT_CMD)        if [ "$G_BE_LANGUAGE" = python ]; then echo "Backend lint command|${py_run:+$py_run }ruff check .|"; else echo "Backend lint command|pnpm lint|"; fi ;;
    BE_FORMAT_CMD)      if [ "$G_BE_LANGUAGE" = python ]; then echo "Backend format command|${py_run:+$py_run }ruff format .|"; else echo "Backend format command|pnpm exec prettier --write .|"; fi ;;
    BE_TYPECHECK_CMD)   if [ "$G_BE_LANGUAGE" = python ]; then echo "Backend typecheck command|${py_run:+$py_run }mypy src|"; else echo "Backend typecheck command|pnpm exec tsc --noEmit -p tsconfig.build.json|"; fi ;;
    BE_TEST_CMD)        if [ "$G_BE_LANGUAGE" = python ]; then echo "Backend test command|${py_run:+$py_run }pytest -q|"; else echo "Backend test command|pnpm test|"; fi ;;
    BE_TEST_SINGLE_CMD) if [ "$G_BE_LANGUAGE" = python ]; then echo "Backend single test file command (path appended)|${py_run:+$py_run }pytest -q|"; else echo "Backend single test file command (path appended)|pnpm exec jest --runInBand|"; fi ;;
    BE_BUILD_CMD)       if [ "$G_BE_LANGUAGE" = python ]; then echo "Backend build command|${py_run:+$py_run }python -m compileall -q src|"; else echo "Backend build command|pnpm build|"; fi ;;
    BE_MIGRATE_CMD)     echo "Backend migration command|${py_run:+$py_run }alembic upgrade head|" ;;
    MAIN_BRANCH)        echo "Main branch (pull requests target)|master|" ;;
    DEV_BRANCH)         echo "Development branch (pull requests target; same as main if none)|develop|" ;;
    EXTERNAL_ID_NAME)   echo "Name of the external identifier field|ref|" ;;
    PAGE_DEFAULT_LIMIT) echo "Default page size for list endpoints|25|" ;;
    PAGE_MAX_LIMIT)     echo "Maximum page size for list endpoints|100|" ;;
    CANONICAL_ENTITY)   echo "Entity to copy for new repositories (hexagonal; - if none yet)||" ;;
    CANONICAL_RESOURCE) echo "Route module to copy for new resources (hexagonal; - if none yet)||" ;;
    *)                  echo "$1||" ;;
  esac
}

ANSWER_FILE_IN=""; ANSWER_TMP=""
# recorded NAME → the value already given in this session or in the answers files, else the placeholder itself
recorded() {
  local v="" src
  for src in "$ANSWER_TMP" "$ANSWER_FILE_IN" "$ANSWER_EXISTING"; do
    [ -n "$src" ] && [ -f "$src" ] && [ -z "$v" ] && v="$(grep -E "^$1=" "$src" | head -1 | cut -d= -f2-)"
  done
  if [ -z "$v" ]; then v="{{$1}}"; fi
  printf '%s' "$v"
}
# answer NAME → prints the value: from the answers file(s), else prompts. Empty = leave.
answer() {
  local n="$1" desc def allowed val prompt ok
  desc="$(describe "$n")"; allowed="${desc##*|}"; desc="${desc%|*}"; def="${desc#*|}"; desc="${desc%%|*}"
  val=""
  for src in "$ANSWER_TMP" "$ANSWER_FILE_IN" "$ANSWER_EXISTING"; do
    [ -n "$src" ] && [ -f "$src" ] && [ -z "$val" ] && val="$(grep -E "^$n=" "$src" | head -1 | cut -d= -f2-)"
  done
  if [ -n "$val" ]; then printf '%s' "$val"; return 0; fi
  [ "$NONINTERACTIVE" -eq 1 ] && { echo "  leave  $n (not in answers file; no terminal to ask)" >&2; return 0; }
  while :; do
    if [ -n "$allowed" ]; then prompt="  $desc ($(echo "$allowed" | tr -d "'" | sed 's/ / | /g')) [$def]: "
    elif [ -n "$def" ]; then prompt="  $desc [$def]: "; else prompt="  $desc: "; fi
    printf '%s' "$prompt" >&2; IFS= read -r val || val="-"
    [ -n "$val" ] || val="$def"
    [ "$val" = "-" ] && { echo "  leave  $n" >&2; return 0; }
    case "$n" in
      *_PORT|*_LIMIT|COMMIT_TITLE_MAX)
        case "$val" in ''|*[!0-9]*) echo "  please enter a whole number" >&2; continue ;; esac ;;
    esac
    [ -z "$allowed" ] && break
    ok=0; for a in $(echo "$allowed" | sed "s/'on request'/on_request/"); do [ "$val" = "${a//_/ }" ] && ok=1; done
    [ "$ok" -eq 1 ] && break
    echo "  please answer one of: $allowed" >&2
  done
  printf '%s' "$val"
}

record() { [ -n "$2" ] && printf '%s=%s\n' "$1" "$2" >> "$ANSWER_TMP"; return 0; }

render_template() {   # render_template <template> <target-relative-path> <conds>
  local src="$1" rel="$2" conds="$3" dest
  rel="${rel#./}"; dest="$ROOT/$rel"
  if [ -e "$dest" ]; then echo "  skip   $rel (exists)"; else
    mkdir -p "$(dirname "$dest")"; cp "$src" "$dest"; strip_conditionals "$dest" "$conds"; echo "  render $rel"
  fi
  grep -qxF "$rel" "$ROOT/.agents/.kit-files" 2>/dev/null || echo "$rel" >> "$ROOT/.agents/.kit-files"
}

configure() {
  ROOT="$1"; ANSWER_FILE_IN="$2"
  ANSWER_EXISTING="$ROOT/.agents/.kit-answers"
  ANSWER_TMP="$(mktemp)"
  # With --answers, a value the file lacks is asked when a terminal is attached and left otherwise (CI, pipes).
  NONINTERACTIVE=0; if [ -n "$ANSWER_FILE_IN" ] && ! [ -t 0 ]; then NONINTERACTIVE=1; fi
  if [ -n "$ANSWER_FILE_IN" ] && [ ! -f "$ANSWER_FILE_IN" ]; then echo "answers file not found: $ANSWER_FILE_IN" >&2; exit 1; fi

  echo "Configure $ROOT"
  [ -z "$ANSWER_FILE_IN" ] || echo "Answers from $ANSWER_FILE_IN; only missing values are asked."
  [ "$NONINTERACTIVE" -eq 1 ] || echo "Enter = accept the suggestion, '-' = leave the placeholder for later."

  # ---- phase 1: shape -------------------------------------------------------
  echo; echo "— Shape"
  G_PROJECT_NAME="$(answer PROJECT_NAME)";   record PROJECT_NAME "$G_PROJECT_NAME"
  G_PROJECT_SHAPE="$(answer PROJECT_SHAPE)"; record PROJECT_SHAPE "$G_PROJECT_SHAPE"
  [ -n "$G_PROJECT_SHAPE" ] || { echo "PROJECT_SHAPE is required" >&2; exit 1; }
  if [ "$G_PROJECT_SHAPE" != backend ]; then
    G_FE_DIR="$(answer FE_DIR)"; record FE_DIR "$G_FE_DIR"
    G_FE_PACKAGE_MANAGER="$(answer FE_PACKAGE_MANAGER)"; record FE_PACKAGE_MANAGER "$G_FE_PACKAGE_MANAGER"
  fi
  if [ "$G_PROJECT_SHAPE" != frontend ]; then
    G_BE_LANGUAGE="$(answer BE_LANGUAGE)"; record BE_LANGUAGE "$G_BE_LANGUAGE"
    G_BE_DIR="$(answer BE_DIR)"; record BE_DIR "$G_BE_DIR"
    G_BE_PACKAGE_MANAGER="$(answer BE_PACKAGE_MANAGER)"; record BE_PACKAGE_MANAGER "$G_BE_PACKAGE_MANAGER"
  fi
  G_DATABASE="$(answer DATABASE)"; record DATABASE "$G_DATABASE"
  G_REDIS="$(answer REDIS)";       record REDIS "$G_REDIS"
  G_CI="$(answer CI)";             record CI "$G_CI"

  local conds=""
  case "$G_PROJECT_SHAPE" in
    frontend)  conds="FRONTEND FRONTEND_ONLY STANDALONE" ;;
    backend)   conds="BACKEND BACKEND_ONLY STANDALONE" ;;
    fullstack) conds="FRONTEND BACKEND FULLSTACK MONOREPO" ;;
  esac
  case "$G_BE_LANGUAGE" in typescript) conds="$conds BACKEND_NODE" ;; python) conds="$conds BACKEND_PYTHON" ;; esac
  case "$G_FE_PACKAGE_MANAGER" in pnpm) conds="$conds FE_PNPM" ;; npm) conds="$conds FE_NPM" ;; esac
  case "$G_BE_PACKAGE_MANAGER" in pip) conds="$conds BE_PIP" ;; uv) conds="$conds BE_UV" ;; poetry) conds="$conds BE_POETRY" ;; esac
  case "$G_DATABASE" in postgres) conds="$conds DB_POSTGRES" ;; mongo) conds="$conds DB_MONGO" ;; *) conds="$conds DB_NONE" ;; esac
  # A pnpm workspace at the repo root exists only when both sides are Node (shared JS packages).
  # Otherwise each side is self-contained and builds from its own folder.
  if [ "$G_PROJECT_SHAPE" = fullstack ] && [ "$G_BE_LANGUAGE" = typescript ]; then conds="$conds BE_ROOT_CONTEXT FE_ROOT_CONTEXT PNPM_WORKSPACE"; else conds="$conds BE_DIR_CONTEXT FE_DIR_CONTEXT"; fi
  [ "$G_REDIS" = yes ] && conds="$conds REDIS"
  [ "$G_CI" = yes ] && conds="$conds CI"
  echo "  shape: $conds"

  # ---- phase 2: render ------------------------------------------------------
  echo; echo "— Render"
  while IFS= read -r -d '' f; do strip_conditionals "$f" "$conds"; done < <(kit_files "$ROOT")
  render_template "$TPL/Makefile" "Makefile" "$conds"
  render_template "$TPL/docker-compose.yml" "docker-compose.yml" "$conds"
  render_template "$TPL/dockerignore" ".dockerignore" "$conds"
  # a build whose context is a side folder only sees that folder's .dockerignore
  if [ -n "$G_BE_DIR" ] && [ "${G_BE_DIR%/}" != "." ] && [[ " $conds " == *" BE_DIR_CONTEXT "* ]]; then render_template "$TPL/dockerignore" "${G_BE_DIR%/}/.dockerignore" "$conds"; fi
  if [ -n "$G_FE_DIR" ] && [ "${G_FE_DIR%/}" != "." ] && [[ " $conds " == *" FE_DIR_CONTEXT "* ]]; then render_template "$TPL/dockerignore" "${G_FE_DIR%/}/.dockerignore" "$conds"; fi
  if [ -n "$G_FE_DIR" ]; then render_template "$TPL/Dockerfile.frontend-next" "${G_FE_DIR%/}/Dockerfile" "$conds"; fi
  if [ -n "$G_BE_DIR" ]; then
    case "$G_BE_LANGUAGE" in
      python) render_template "$TPL/Dockerfile.backend-python" "${G_BE_DIR%/}/Dockerfile" "$conds" ;;
      *)      render_template "$TPL/Dockerfile.backend-node"   "${G_BE_DIR%/}/Dockerfile" "$conds" ;;
    esac
  fi
  if [ "$G_CI" = yes ]; then
    render_template "$TPL/github/ci.yml" ".github/workflows/ci.yml" "$conds"
  fi

  # ---- phase 3: values ------------------------------------------------------
  echo; echo "— Values"
  local present names n val
  present="$(kit_files "$ROOT" | xargs -0 cat 2>/dev/null | sed -E 's/`[^`]*`//g' | grep -oE '\{\{[A-Za-z_-]+\}\}' | sed -E 's/^\{\{//; s/\}\}$//' | sort -u || true)"
  names=""
  for n in $GATES $KNOWN_ORDER; do echo "$present" | grep -qx "$n" && names="$names $n"; done
  for n in $present; do echo "$GATES $KNOWN_ORDER" | tr ' ' '\n' | grep -qx "$n" || names="$names $n"; done
  for n in $names; do
    val="$(answer "$n")"
    [ -n "$val" ] || continue
    record "$n" "$val"
    while IFS= read -r -d '' f; do
      if grep -q "{{$n}}" "$f"; then sed -e "s|{{$n}}|$(sed_escape "$val")|g" "$f" > "$f.kit.tmp" && mv "$f.kit.tmp" "$f"; fi
    done < <(kit_files "$ROOT")
  done

  # normalise paths like ./. (a side that lives at the repo root) now that the values are in
  while IFS= read -r -d '' f; do
    if grep -q '\./\./\|/\./' "$f" 2>/dev/null; then sed -e 's#\./\./#./#g; s#/\./#/#g; s#\./\.$#.#; s#"\./\.#"\.#g' "$f" > "$f.kit.tmp" && mv "$f.kit.tmp" "$f"; fi
  done < <(kit_files "$ROOT")

  # ---- save -----------------------------------------------------------------
  { [ -f "$ANSWER_EXISTING" ] && grep -v '^#' "$ANSWER_EXISTING"; cat "$ANSWER_TMP"; } \
    | awk -F= 'NF { a[$1]=$0 } END { for (k in a) print a[k] }' | sort > "$ANSWER_EXISTING.kit.tmp"
  { echo "# agents-kit answers — reuse with: init.sh <repo> --answers .agents/.kit-answers"; cat "$ANSWER_EXISTING.kit.tmp"; } > "$ANSWER_EXISTING"
  rm -f "$ANSWER_EXISTING.kit.tmp" "$ANSWER_TMP"
  echo
  echo "Saved answers to .agents/.kit-answers"
  echo "Next: run 'make' to see the targets; '$0 $ROOT --check' lists the TODO(project) sections left."
}

if [ "$CONFIGURE" -eq 1 ]; then
  [ -n "$TARGET" ] || usage 1
  [ -d "$TARGET/.agents" ] || { echo "no .agents/ in $TARGET — run the copy first" >&2; exit 1; }
  configure "$(cd "$TARGET" && pwd)" "$ANSWERS"
  exit 0
fi

# ------------------------------------------------------------------ copy ----
[ -n "$TARGET" ] || usage 1
[ -d "$TARGET" ] || { echo "not a directory: $TARGET" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"
[ "$TARGET" != "$KIT_DIR" ] || { echo "refusing to copy the kit onto itself" >&2; exit 1; }

copied=0; skipped=0
while IFS= read -r -d '' src; do
  rel="${src#$KIT_DIR/}"; dest="$TARGET/$rel"
  if [ -e "$dest" ]; then echo "  skip   $rel (exists)"; skipped=$((skipped + 1))
  else mkdir -p "$(dirname "$dest")"; cp "$src" "$dest"; echo "  copy   $rel"; copied=$((copied + 1)); fi
done < <(find "$KIT_DIR/.agents" -type f -print0)

if [ "$WITH_CLAUDE" -eq 1 ]; then
  if [ -e "$TARGET/CLAUDE.md" ]; then echo "  skip   CLAUDE.md (exists)"; skipped=$((skipped + 1))
  else cp "$KIT_DIR/CLAUDE.md.template" "$TARGET/CLAUDE.md"; echo "  copy   CLAUDE.md"; copied=$((copied + 1)); fi
fi

linked=0
if [ -d "$TARGET/.agents/skills" ]; then
  for skill in "$TARGET"/.agents/skills/*/; do
    [ -d "$skill" ] || continue
    name="$(basename "$skill")"
    [ -f "$skill/SKILL.md" ] || continue
    case "$name" in _*) continue ;; esac
    linkpath="$TARGET/.claude/skills/$name"
    if [ -e "$linkpath" ] || [ -L "$linkpath" ]; then echo "  skip   .claude/skills/$name (exists)"
    else mkdir -p "$TARGET/.claude/skills"; ln -s "../../.agents/skills/$name" "$linkpath"; echo "  link   .claude/skills/$name -> ../../.agents/skills/$name"; linked=$((linked + 1)); fi
  done
fi

echo "Done: $copied copied, $skipped skipped, $linked linked."
echo "Next: $0 $TARGET --configure   (then --check for what is left)"
