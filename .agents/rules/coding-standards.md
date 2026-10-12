# Coding standards

**Read this when:** writing any code in this repository.

Language and style baseline for this project:
<!-- {{IF FRONTEND}} -->
- frontend: **TypeScript / React** ({{FE_STACK}}) in {{FE_DIR}}/
<!-- {{ENDIF}} -->
<!-- {{IF BACKEND_NODE}} -->
- backend: **TypeScript / Node** ({{BE_FRAMEWORK}}) in {{BE_DIR}}/
<!-- {{ENDIF}} -->
<!-- {{IF BACKEND_PYTHON}} -->
- backend: **Python** ({{BE_FRAMEWORK}}) in {{BE_DIR}}/; the Zen of Python
  (PEP 20) applies to all of it: explicit over implicit, flat over nested,
  early returns, no clever one-liners
<!-- {{ENDIF}} -->

A language-wide guide installed as a skill applies first; this file holds the
project-specific rules.

## Simplicity is a hard rule

- **Keep it simple.** The smallest change that satisfies the request, in the
  style of the surrounding code.
- **No speculative abstractions.** Build for the current requirement; extract
  a helper when a second real caller appears, not before.
- **No new dependency, library or pattern** without explicit approval.

## Naming and shape

<!-- TODO(project): adjust to the language(s). The TypeScript defaults below are an example; for Python read `snake_case`, type hints on public functions, no `import *`. -->

- `camelCase` for variables and functions, `PascalCase` for classes and
  types, `UPPER_SNAKE_CASE` for constants.
- Strict typing on; avoid escape hatches (`any`, untyped dicts) on public
  surfaces.
- Prefer nullish operators (`??`, `?.`) over truthiness checks when the
  distinction matters.
- Prefer the namespaced standard function over the global one where both
  exist (`Number.parseInt` over `parseInt`).
- **No nested ternaries.** Extract a helper, an `if/else` or a `switch`.
- Extract repeated union or shape types to a named alias.
- Destructure when it improves readability, not by reflex.
- `async/await` over raw promise chains.

## Comments and documentation

- Docblocks on public functions: what it does, what it returns, what it
  throws.
- `// TODO:` and `// FIXME:` for known follow-ups, with what and why.
- A non-obvious decision gets a one-line comment stating the reason.
- No commented-out code.

## Files and modules

<!-- TODO(project): module layout rules, import ordering, barrel-file policy, file naming. -->

## Do / Do not

- Do: read the surrounding files before writing; match their style.
- Do: batch independent reads and edits in one step.
- Do not: reformat code you did not change.
- Do not: change formatter, linter or compiler settings as a side effect.
- Do not: leave diagnostic logging in the change that fixes a bug.

## Reference files

| Need | Reference file |
| --- | --- |
| A typical service / module | <!-- TODO(project) --> `src/…` |
| A typical test | <!-- TODO(project) --> `src/…` |

## Scope discipline

- Do not migrate code from one style to another unless the task is that
  migration.
- Do not introduce a second way of doing something the codebase already does.
