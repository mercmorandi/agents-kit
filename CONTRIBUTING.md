# Contributing

Thanks for taking the time. The kit is small on purpose; the bar for a change
is that it makes a rendered project better for the agent working in it.

## Ground rules

- **Templates stay project-agnostic.** Nothing from a specific product,
  company or account. A good test: would this line be true in a project you
  have never seen?
- **Never overwrite.** `init.sh` creates files and skips existing ones. Keep
  it that way; merging is the user's job.
- **The Makefile is the contract.** Documents and CI say `make <target>`.
  A new capability gets a make target first, then a mention.
- **A real placeholder is never inside backticks.** `--check` and
  `--configure` treat backticked `{{NAMES}}` as quoted documentation.
- **Every conditional has a fixture.** A new `{{IF X}}` needs a fixture in
  `tests/fixtures/` where X is true and one where it is false.
- Bash 3.2 compatible (macOS default): no associative arrays, no `mapfile`,
  no `local a=1 b=$a`.

## Workflow

1. Fork, branch from `main`.
2. Make the change. If it adds a value, add it to `KNOWN_ORDER` and
   `describe()` in `init.sh`, to the `--help` text and to the README table.
3. Run the suite:

   ```bash
   tests/run.sh -v
   ```

   Install `shellcheck`, `actionlint` and `hadolint` to run the skipped
   checks locally; CI runs all of them.

4. Open a pull request. Describe why, what changed and what you ran.
   Conventional commit titles (`feat:`, `fix:`, `docs:`), 50 characters.

## Adding a template

Put it in `templates/`, render it from `configure()` with `render_template`,
record its conditions, and make sure `tests/run.sh` validates it (a linter if
one exists, otherwise at least a structural check). Document it in the
"What `--configure` renders" table of the README.

## Reporting a bug

Open an issue with the answers file (`.agents/.kit-answers`, secrets
removed) and the command you ran. That reproduces almost everything.
