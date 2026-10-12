# {{Feature}} — hand-off

> **Branch:** `<branch>` · **Baseline:** `<commit>` · **State:** changes
> <committed / NOT committed — the owner commits them>
> **Honest scope:** <what this hand-off deliberately does not cover>

You are taking over this work. Read in this order, then proceed.

## 1. Read first, in this order

1. This file.
2. [PLAN](PLAN.md) — the source of truth for what and why.
3. [PROGRESS](PROGRESS.md) — where the sequence stands.
4. `../../rules/<area>.md` and `../../patterns/<task>-pattern.md` for the
   layer you will touch.
5. Root `CLAUDE.md` if you will write code.

## 2. Decided — do not reopen

- D1: … (reason in PLAN §4).
- …

## 3. What was done

Per item: why · files · delta. Summary first, detail below.

| Item | Why | Files | Delta |
| --- | --- | --- | --- |

## 4. Key decisions taken during implementation

Correctness and security choices a reviewer must know, with the alternative
rejected.

## 5. Verification actually run

Real pass/fail only. Anything not executed is PENDING.

| Check | Command | Result |
| --- | --- | --- |
| | | pass / fail / PENDING |

## 6. NOT done — follow-up

- …

## 7. Done when

- [ ] …
- [ ] grep gate: `grep -rn "<symbol>" src/` returns nothing.
- [ ] PROGRESS and MILESTONES updated.

## 8. Local state to know about

Environment variables, running services, data left in a local store,
fixtures in `tmp/`. No secrets; name the variable, not the value.

## 9. Suggested commit (the owner makes it)

```
type(scope): title within {{COMMIT_TITLE_MAX}} characters

Body: why, what to review.
```

```bash
# run from repo root
git add <files>
```

Optional split into separate commits, in dependency order.
