#!/usr/bin/env bash
# End-to-end smoke test: render the fullstack Python fixture, drop a minimal
# FastAPI app and a minimal Next.js app into it, build both images with the
# generated Dockerfiles through the generated docker-compose.yml, start the
# stack, wait for every healthcheck, hit the services, tear down.
#
#   tests/smoke.sh            needs docker; pnpm and uv are run inside containers
#
# Host ports are remapped (3100 / 8100 / 27117) so a developer's own stack can
# stay up. Takes about a minute with warm image caches.
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="$KIT/tests/fixtures/fullstack-python-postgres.answers"
WORK="$(mktemp -d)"; REPO="$WORK/smoke"
export COMPOSE_PROJECT_NAME="agentskit-smoke-$$"
cleanup() {
  (cd "$REPO" 2>/dev/null && docker compose down -v --rmi local >/dev/null 2>&1) || true
  rm -rf "$WORK" 2>/dev/null || { docker run --rm -v "$WORK:/w" alpine:3 sh -c 'rm -rf /w/*' >/dev/null 2>&1 || true; rm -rf "$WORK" 2>/dev/null || true; }
}
# containers that write into the checkout run as the invoking user, with a writable HOME
AS_ME=(--user "$(id -u):$(id -g)" -e HOME=/tmp)
trap cleanup EXIT
step() { echo; echo "### $1"; }

step "render the scaffold from $(basename "$FIXTURE")"
mkdir -p "$REPO"
"$KIT/init.sh" "$REPO" >/dev/null
"$KIT/init.sh" "$REPO" --answers "$FIXTURE" < /dev/null | grep -E "^  render"
cd "$REPO"
FE_DIR="$(sed -n 's/^FE_DIR=//p' "$FIXTURE")"; BE_DIR="$(sed -n 's/^BE_DIR=//p' "$FIXTURE")"
PNPM="$(sed -n 's/^PNPM_VERSION=//p' "$FIXTURE")"; NODE="$(sed -n 's/^NODE_VERSION=//p' "$FIXTURE")"; PY="$(sed -n 's/^PYTHON_VERSION=//p' "$FIXTURE")"

step "backend: minimal FastAPI app, lockfile generated in a container"
mkdir -p "$BE_DIR/src/api"
cat > "$BE_DIR/pyproject.toml" <<'PYT'
[project]
name = "smoke-server"
version = "0.0.1"
requires-python = ">=3.12"
dependencies = ["fastapi>=0.115", "uvicorn[standard]>=0.30"]
PYT
touch "$BE_DIR/src/__init__.py" "$BE_DIR/src/api/__init__.py"
cat > "$BE_DIR/src/api/main.py" <<'PYT'
from fastapi import FastAPI
app = FastAPI()
@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
PYT
docker run --rm "${AS_ME[@]}" -v "$PWD/$BE_DIR:/app" -w /app "ghcr.io/astral-sh/uv:python${PY}-bookworm-slim" uv lock >/dev/null

step "frontend: minimal Next.js app (standalone), lockfile generated in a container"
mkdir -p "$FE_DIR/app" "$FE_DIR/public"
cat > "$FE_DIR/package.json" <<'JSON'
{ "name": "smoke-client", "private": true, "version": "0.0.1",
  "scripts": { "build": "next build", "dev": "next dev", "start": "next start" },
  "dependencies": { "next": "15.5.4", "react": "19.1.1", "react-dom": "19.1.1" } }
JSON
echo "module.exports = { output: 'standalone' };" > "$FE_DIR/next.config.js"
cat > "$FE_DIR/app/layout.js" <<'JS'
export default function RootLayout({ children }) {
  return <html lang="en"><body>{children}</body></html>;
}
JS
echo "export default function Page() { return <main>smoke ok</main>; }" > "$FE_DIR/app/page.js"
touch "$FE_DIR/public/.gitkeep"
docker run --rm "${AS_ME[@]}" -v "$PWD/$FE_DIR:/app" -w /app "node:${NODE}-alpine" sh -c "npm_config_cache=/tmp/npm npx --yes pnpm@${PNPM} install --lockfile-only --config.store-dir=/tmp/store >/dev/null"
test -f "$FE_DIR/pnpm-lock.yaml"

step "remap host ports"
sed -i.bak -e 's/"3000:3000"/"3100:3000"/; s/"8000:8000"/"8100:8000"/; s/"5432:5432"/"5433:5432"/; s/"27017:27017"/"27117:27017"/' docker-compose.yml && rm -f docker-compose.yml.bak

step "docker compose build"
docker compose build --quiet

step "docker compose up --wait (every healthcheck must pass)"
docker compose up -d --wait --wait-timeout 180
docker compose ps --format 'table {{.Service}}\t{{.Status}}'

step "hit the services"
curl -fsS http://localhost:8100/health | grep -q '"ok"' && echo "backend /health ok"
curl -fsS http://localhost:3100/ | grep -q "smoke ok" && echo "frontend / ok"
docker compose exec -T backend id -u | grep -qv '^0$' && echo "backend runs as non-root"
docker compose exec -T frontend id -u | grep -qv '^0$' && echo "frontend runs as non-root"

echo; echo "SMOKE OK"
