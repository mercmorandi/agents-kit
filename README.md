# agents-kit

**A project-agnostic `.agents/` folder, Makefile, Docker and CI scaffold for
repositories built with coding agents.**

Drop it into a new repository, answer a few questions, and the agent starts
every session with the same working protocol, the same document shapes, the
same rule skeletons and the same `make` targets you already trust. The next
project reuses your answers.

```bash
~/agents-kit/init.sh .              # copy .agents/ and CLAUDE.md, never overwriting
~/agents-kit/init.sh . --configure  # shape → scaffold → values
make                                # see what you got
```

## Why

Coding agents are good at code and bad at memory. Every new session they
re-derive how the team works, every new repository starts from an empty
`CLAUDE.md`, and the conventions that matter most (how to verify, how to hand
over, what never to do) live in people's heads or in chat history.

This kit fixes three things at once:

- **Process is a folder, not a habit.** `.agents/workflow/` says how the
  agent works: the per-task loop, when to stop and ask, what counts as
  verified, how a hand-off looks. It is project-agnostic and copied as is.
- **Rules point at files.** Every rule ends with a table of canonical files
  to copy and a "scope discipline" section. Every pattern names one example
  and says "reproduce that exact shape".
- **The Makefile is the contract.** `CLAUDE.md`, the workflow documents and
  the CI all say `make lint`, `make build`, `make test-file FILE=…`. The
  real per-side commands live in the Makefile only, so the agent's
  instructions are identical in every project, whatever the stack.

## What you get

```
your-repo/
├── CLAUDE.md                 entry point: reading order, canonical references, hard rules, gotchas
├── Makefile                  install / dev / lint / typecheck / test / test-file / build / up / logs …
├── docker-compose.yml        local stack: your sides + postgres or mongo + redis, as chosen
├── .dockerignore
├── client/Dockerfile         Next.js standalone, multi-stage, non-root, healthcheck      (frontend)
├── server/Dockerfile         Node (pnpm deploy) or Python (venv, uvicorn), non-root       (backend)
├── .github/workflows/ci.yml  PR checks per side through the make targets + docker build  (CI = yes)
└── .agents/
    ├── workflow/             how the agent works: session loop, planning, verification, hand-off, safety
    ├── rules/                what holds here: architecture (layered or hexagonal), API, errors, tests, security, docs
    ├── patterns/             recipes to copy: repository adapter, entrypoint module, + template
    ├── plans/                PLAN / PROGRESS / HANDOFF / KICKOFF / MILESTONES templates
    └── skills/               on-demand reference, exposed to Claude Code via .claude/skills/ symlinks
```

A configure session, abridged:

```
— Shape
  Project name (compose project, image names) [my-app]:
  Project shape (frontend | backend | fullstack) [fullstack]:
  Backend language (typescript | python) [typescript]: python
  Backend package manager (pip | uv | poetry) [uv]:
  Database (local compose + CI service) (postgres | mongo | none) [postgres]:
  GitHub Actions CI (lint, typecheck, tests, docker build on pull requests) (yes | no) [yes]:
— Render
  render Makefile
  render docker-compose.yml
  render client/Dockerfile
  render server/Dockerfile
  render .github/workflows/ci.yml
— Values
  Language of replies to the human [English]: Italian
  Commit ownership: never / on request / always (never | on request | always) [never]:
  Backend test command [uv run pytest -q]:
  …
Saved answers to .agents/.kit-answers
```

Every question has a default that follows your earlier answers (`uv run
pytest` once you chose uv). Enter accepts, `-` leaves the placeholder for
later. The questions you see depend on the shape: no frontend questions in a
backend-only project.

## The ideas behind it

- **Reading order over auto-loading.** The agent discovers documents through
  a prose list in `CLAUDE.md`, each line with a trigger ("read before
  touching `/admin/*`"). Only skills auto-load, via `paths:` frontmatter.
  Nothing is magic; everything is greppable.
- **Honest status.** A test is "passed" only when it ran in this session;
  everything else is PENDING. The hand-off says what was NOT done, and opens
  with a plain-words paragraph a non-developer can read.
- **Scope discipline.** Only what was asked. Off-scope problems are reported
  with evidence, not silently fixed. No new dependency, abstraction or
  pattern without approval.
- **Plans carry their own verification.** A plan without "Verification" and
  "How this was measured" is a wish. Decisions record the alternatives they
  rejected, so nobody reopens them.
- **Templates are a starting point, not a framework.** Delete what does not
  apply, edit the rest. The kit never overwrites a file you already have.

## Rule, pattern, plan or skill?

| You want to write down… | It is a… |
| --- | --- |
| "Never return a bare list from an endpoint" | **rule** — a constraint that always holds in one area |
| "To add a list endpoint: copy `x.ts`, then …" | **pattern** — a recipe with one canonical file to copy |
| "We are adding bookmarks; here are the API, the steps, the checks" | **plan** — feature-scoped, has a lifecycle, ends |
| "Everything about testing async services with this framework" | **skill** — large, topic-scoped, loaded only when the task matches |
| "The agent must stop and ask before adding a dependency" | **workflow** — how the agent behaves, not about this codebase |

The full taxonomy, with the reading order an agent follows, is in
[`.agents/README.md`](.agents/README.md).

## Adopt it in three steps

1. **Copy.** `.agents/` plus the `CLAUDE.md` entry point at the root.
   Existing files are never overwritten (`skip` is printed). `--no-claude-md`
   leaves the root alone on purpose.

   ```bash
   ~/agents-kit/init.sh /path/to/repo
   ```

2. **Configure.** Shape gates, then the scaffold, then the values. Answers
   are saved to `.agents/.kit-answers` and the next project reuses them.
   Values the file contains are applied silently, missing ones are asked
   (or left for later when no terminal is attached, as in CI):

   ```bash
   ~/agents-kit/init.sh /path/to/repo --configure
   ```

   ```bash
   ~/agents-kit/init.sh /path/to/other-repo --answers /path/to/repo/.agents/.kit-answers
   ```

3. **Fill what needs the codebase.** What remains are
   `<!-- TODO(project): … -->` sections: tables of canonical files, gotchas,
   diagnostic scripts. They need code to exist. List them with:

   ```bash
   ~/agents-kit/init.sh /path/to/repo --check
   ```

   Then delete what does not apply (a rule about an API in a frontend-only
   project) and remove its line from the `CLAUDE.md` reading order.

## What `--configure` renders

| File | Content | When |
| --- | --- | --- |
| `Makefile` | The single entry point. Aggregate targets (`lint`, `typecheck`, `test`, `build`, `install`) call per-side ones (`lint-frontend`, `lint-backend`, …), so CI runs one side at a time. `make test-file FILE=…` runs one test file. Docker targets: `up`, `down`, `logs`, `up-backend` (rebuild, restart, tail). Self-documenting `make`. | always |
| `docker-compose.yml` | Your sides built from their Dockerfiles, plus postgres or mongo (healthcheck, volume) and redis as chosen. | always |
| `.dockerignore` | At the root and in every folder used as a build context. | always |
| `<FE_DIR>/Dockerfile` | Next.js standalone output, multi-stage, non-root, healthcheck. With a Node backend the two sides share a pnpm workspace at the root and the image installs with `pnpm --filter`; with any other backend the frontend is self-contained in its folder. | frontend |
| `<BE_DIR>/Dockerfile` | Node: build, then `pnpm deploy --prod`. Python: venv built with pip, uv or poetry, slim runner, uvicorn. Both non-root with healthcheck. | backend |
| `.github/workflows/ci.yml` | Pull-request checks per side through the make targets, a database service container when the project has one, a docker build of each image, one status job to protect the branch with. Monorepo: `paths-filter` runs only the side that changed. | CI = yes |

Deployment is deliberately out of scope: a deploy pipeline is specific to
the platform and the account it targets. The CI gives you the gate a deploy
workflow would depend on.

## How `--configure` works

**Phase 1, shape.** Gate questions: `PROJECT_SHAPE` (`frontend | backend |
fullstack`, fullstack meaning both sides in one repository: a pnpm workspace
when both are Node, two self-contained apps side by side otherwise), `BE_LANGUAGE`
(`typescript | python`), the folders of each side, package managers,
`DATABASE` (`postgres | mongo | none`), `REDIS`, `CI`.

**Phase 2, render.** Conditional blocks (`{{IF X}} … {{ENDIF}}`) in
`CLAUDE.md` and `.agents/` are resolved and the scaffold files above are
created, never overwriting.

**Phase 3, values.** Every remaining `{{PLACEHOLDER}}` is asked once, in a
fixed order, then replaced everywhere it appears.

| You type | Effect |
| --- | --- |
| Enter | accept the suggested value shown in `[brackets]` |
| Enter, no `[brackets]` | the question has no default: the placeholder is left as is |
| `-` | leave the placeholder for later, ignoring the suggestion |
| anything else | that value, verbatim; closed lists and numbers are validated |

Re-running `--configure` asks only for what is still open. A placeholder
written inside backticks is treated as quoted documentation and is neither
asked nor replaced.

### The values

**Working rules** (`.agents/workflow/`): how the agent behaves with you.

| Placeholder | Meaning | Values |
| --- | --- | --- |
| `CHAT_LANGUAGE` | Language of replies to the human | e.g. Italian |
| `CODE_LANGUAGE` | Code, comments, commits, dev docs | e.g. English |
| `DOC_LANGUAGE` | Plan and milestone documents | e.g. English |
| `AGENT_COMMITS` | **Who runs `git commit`.** `never`: the agent hands over the file list and a suggested message, you commit. `on request`: only when told to, one commit per logical task. `always`: each verified milestone, on its branch. Push, PRs and the remote are governed by `GIT_REMOTE_POLICY`, not here. | `never` / `on request` / `always` |
| `COMMIT_TITLE_MAX` | Hard max length of a commit title | e.g. 50 |
| `MILESTONE_CADENCE` | Stop after each verified milestone, or keep going | `stop after each milestone` / `chain until told` |
| `GIT_REMOTE_POLICY` | What the agent may do with the git remote | e.g. `never fetch, pull or push` |
| `ENVIRONMENTS` | Named environments and which one the agent may touch | e.g. `dev only; staging and prod on explicit instruction` |
| `PLAN_DATES_POLICY` | Whether plan documents carry dates | e.g. `no dates; git carries the when` |

**Project facts** (`CLAUDE.md`, `Makefile`, Docker, CI): asked only when the
shape needs them.

| Placeholder | Meaning |
| --- | --- |
| `PROJECT_NAME`, `AUTH` | Compose project and image names; the auth provider named in `CLAUDE.md` |
| `NODE_VERSION`, `PNPM_VERSION`, `PYTHON_VERSION` | Runtime and package-manager versions pinned in Dockerfiles and CI (`pnpm@latest` is never used: a major bump changes install behaviour) |
| `INSTALL_CMD`, `FE_INSTALL_CMD`, `BE_INSTALL_CMD` | What `make install`, `make install-frontend`, `make install-backend` run |
| `FE_STACK`, `FE_PORT`, `FE_PACKAGE_NAME`, `FE_*_CMD` | Frontend facts and the commands behind the frontend make targets |
| `BE_FRAMEWORK`, `BE_PORT`, `BE_PACKAGE_NAME`, `BE_ENTRYPOINT`, `BE_ASGI_APP`, `BE_*_CMD` | Backend facts and commands; `BE_MIGRATE_CMD` for Python |
| `MAIN_BRANCH`, `DEV_BRANCH` | Branches the CI runs on |
| `EXTERNAL_ID_NAME`, `PAGE_DEFAULT_LIMIT`, `PAGE_MAX_LIMIT` | API rules: the public identifier's name, list page sizes |
| `CANONICAL_ENTITY`, `CANONICAL_RESOURCE` | Files to copy for the hexagonal patterns; `-` on a new project |

`init.sh --help` has the same reference, offline.

## Testing the kit

```bash
tests/run.sh -v
```

```bash
tests/smoke.sh
```

`tests/run.sh` is the fast, structural suite. `tests/smoke.sh` is the proof:
it renders the fullstack Python fixture, drops a minimal FastAPI app and a
minimal Next.js app into it, builds both images with the generated
Dockerfiles through the generated `docker-compose.yml`, starts the stack,
waits for every healthcheck, probes `/health` and the home page, and checks
both processes run as non-root. It needs docker only; pnpm and uv run inside
containers. The kit's CI runs both.

Renders every fixture in `tests/fixtures/` (fullstack TypeScript + mongo +
redis, fullstack Python + postgres, backend Python with pip and no database,
frontend-only with npm and no CI) into a temporary repository and checks:
no marker or placeholder left beyond the expected ones, every make target
the documents and the CI mention exists, `docker compose config` passes,
every Dockerfile is non-root with a healthcheck and lints under hadolint,
every build context has a `.dockerignore`, `actionlint` passes, a second run
changes nothing, and the interactive paths (defaults, validation, no gate
asked twice). The GitHub Actions workflow in this repository runs the same
suite with shellcheck, actionlint and hadolint installed.

## Roadmap

- `AGENTS.md` entry point for agents other than Claude Code (Codex, Cursor),
  with `CLAUDE.md` as a symlink.
- An `examples/` project that builds its images and passes the CI for real.
- More Dockerfile flavours (Vite SPA, Go) when a fixture needs them.

## License

[MIT](LICENSE)
