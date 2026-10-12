# Patterns

Approved recipes to copy for one recurring task. A pattern differs from a
rule in two ways: it is **procedural** (numbered steps) and it names **one
canonical example** in the codebase to copy.

## When to write a pattern

- The same task has been done twice and the second copy diverged from the
  first.
- A task needs changes in several places that are easy to forget (register
  here, translate there, add the chip, bump the version).
- A plan's step says "follow the existing pattern" and no document says
  which.

## Rules for a pattern

- One pattern, one task, one canonical example. If two examples are needed,
  the task is two patterns.
- The canonical example is a real file in `src/`, named in the first lines
  with "Reproduce that exact shape unless the use case differs".
- Steps name the exact file to create or edit, with "New file:" where
  applicable, and end with a cleanup step.
- The pattern ends with `Do / Do not` and `Scope discipline`, like a rule.
- When the canonical example changes, the pattern changes in the same
  hand-off.

## Skeleton

See `_TEMPLATE.md`. Name files `<task>-pattern.md`
(`route-module-pattern.md`, `optimistic-update-pattern.md`).

## Files

| File | Task | Canonical example |
| --- | --- | --- |
| `repository-adapter-pattern.md` | Persist a new entity / add an outbound adapter (hexagonal) | <!-- TODO(project) --> |
| `entrypoint-module-pattern.md` | Add a REST resource end to end (hexagonal) | <!-- TODO(project) --> |
| <!-- TODO(project) --> | | |
