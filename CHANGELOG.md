# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed

- Python backend in a fullstack repo built with the repository root as
  context, so `pyproject.toml` was not found; a non-Node backend now builds
  from its own folder and the frontend is self-contained (no root pnpm
  workspace unless both sides are Node).
- Healthchecks used `localhost`, which busybox `wget` resolves to `::1`
  inside Alpine while Next listens on IPv4 only; all healthchecks use
  `127.0.0.1`.
- Dockerfiles and CI used `pnpm@latest`; a major bump (pnpm 12) broke
  `--frozen-lockfile`. The version is pinned through `PNPM_VERSION`.
- CI jobs ran `make install` for both sides in each job; per-side
  `install-frontend` / `install-backend` targets.
- Values given earlier in a session were asked again in the values phase;
  numeric and closed-list answers are validated; package names are asked
  before the install commands that use them.

- Dockerfiles pass hadolint: healthchecks in JSON form, numeric UIDs,
  consolidated RUN layers.

- GitHub Actions pinned to majors on Node 24 (checkout v7, setup-node v7,
  setup-python v7, pnpm/action-setup v6, paths-filter v4, setup-uv v10,
  buildx v4, build-push v7); runner pinned to `ubuntu-24.04` in the template,
  kit CI runs on both 24.04 and 26.04.

### Added

- `tests/smoke.sh`: end-to-end build and run of a rendered project, in CI.
- `--answers` asks for missing values when a terminal is attached.

## [0.1.0]

First public version.

### Added

- `.agents/` kit: `workflow/` (how the agent works), `rules/` baselines
  (layered and hexagonal architecture, API design, errors, testing,
  security, documentation), `patterns/` (repository adapter, entrypoint
  module), `plans/` templates (plan, progress, hand-off, kickoff,
  milestones), `skills/` template.
- `CLAUDE.md.template` entry point with mandatory reading order, canonical
  references, hard rules, gotchas and diagnostic-script sections.
- `init.sh`: copy without overwriting, `--configure` with shape gates and
  cookiecutter-style values, `--answers` for non-interactive reuse,
  `--check` for placeholders and broken links, `--help` manual.
- Scaffold templates rendered by `--configure`: self-documenting `Makefile`
  with per-side targets, `docker-compose.yml` with optional postgres or mongo
  and redis, `.dockerignore` per build context, Dockerfiles for Next.js
  (standalone), Node (pnpm deploy) and Python (venv, pip/uv/poetry), GitHub
  Actions CI running the make targets per side with a docker build.
- Test suite (`tests/run.sh`) rendering four fixtures and validating them;
  GitHub Actions workflow running it with shellcheck, actionlint and hadolint.
