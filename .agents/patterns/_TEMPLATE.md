# Pattern: {{Task}}

**Read this when:** <!-- TODO(project): the trigger, e.g. "adding a new list endpoint" -->

**Copy this when** <!-- TODO(project): the task in one clause -->.
Canonical example: `src/…` <!-- TODO(project) -->. Reproduce that exact shape
unless the use case differs.

## When to use

- …
- Not for: … (use `<other-pattern>.md` instead)

## Flow

1. **New file:** `src/…` — copy from the canonical example; rename …
2. Edit `src/…` — register …
3. Edit `src/…` — add the …
4. Translations / registry / chip: `…`, `…`
5. Test: `src/…` — copy the sibling test; cover the happy path and each
   error class.
6. Cleanup: remove …; update `../rules/<area>.md` if a new canonical example
   was created.

```
<!-- TODO(project): optional ASCII diagram of the files involved and how they relate -->
```

## Rules

- **Hard rule in bold.**
- Rule.

## Example references (canonical, copy then adapt)

| Need | Reference file |
| --- | --- |
| The canonical example | `src/…` |
| A variant | `src/…` |
| The registry to edit | `src/…` |

## Do / Do not

- Do: keep the change narrow to the files above.
- Do: …
- Do not: introduce a new helper or abstraction for this; use what the
  canonical example uses.
- Do not: …

## Scope discipline

- Apply this pattern only when the task asks for a new {{thing}}.
- Do not retrofit existing {{things}} to this shape unless the task is that
  migration.
