# {{Feature}} — plan

> **Status:** draft · **Baseline:** `<commit>` on `<branch>` · **Owner:** <name or role>
> **Companions:** [PROGRESS](PROGRESS.md) · [HANDOFF](HANDOFF.md) · [MILESTONES](MILESTONES.md)
> **Rules it keeps:** `../../rules/<area>.md`, `CLAUDE.md` «<section>»

## Glossary

<!-- Only if abbreviations or codes appear below. Keep it here, at the top. -->

| Term | Meaning |
| --- | --- |
| | |

## 0. TL;DR

Three to six lines: what changes for the user, how big it is (files,
endpoints, PRs), what the owner must decide.

## 1. Scope — what is wrong today

Verified facts, each with a path. Mark anything not verified `UNVERIFIED`.

- `src/…` (`symbol`): …
- …

## 2. Inventory

What exists and is touched: tables per workspace or layer (where · size ·
what · keeps / changes / goes).

## 3. What stays

Explicitly out of the change, so nobody removes it on the way.

## 4. Decisions for the owner

| # | Question | Options | Recommended | Decided |
| --- | --- | --- | --- | --- |
| D1 | | (a) … (b) … | (b), because … | |

The plan proceeds under the recommended option until decided.

## 5. Sequence

Milestones that are each verifiable on their own. One row per milestone.

| # | Milestone | Depends on | Gate (how we know it is done) |
| --- | --- | --- | --- |
| M1 | | — | |
| M2 | | M1 | |

Blocking statements go here, where a partial reading happens: "Do not run M3
before M2's backfill has been verified in PROGRESS."

## 6. Verification

| When | Check | Command / evidence |
| --- | --- | --- |
| Before merge | | `{{TEST_SINGLE_CMD}} …` |
| After deploy | | |

## 7. Risks and rollback

| Risk | Impact | Mitigation | Rollback |
| --- | --- | --- | --- |

## 8. Out of scope

- …

## 9. How this was measured

The commands or scripts used for the inventory and the counts, the baseline
commit, the control check that proves a zero is a real zero. Scripts live in
gitignored `tmp/<feature>/`.
