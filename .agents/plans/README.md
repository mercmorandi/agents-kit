# Plans

Feature-scoped documents with a lifecycle. Write the plan **before** touching
the area it covers; read the matching plan before working on an area.

## One folder per feature

```
plans/<feature>/
├── PLAN.md          what and why, decisions, sequence, verification
├── PROGRESS.md      updated in every PR: what · outcome · why · verification · PR
├── HANDOFF.md       written when another agent or session takes over
├── KICKOFF.md       the next session's entry point; rewritten each iteration
└── MILESTONES.md    plain-language log, no code, for the changelog and non-developers
```

A small feature needs only `PLAN.md`. Add the companions when the work spans
sessions. If the project keeps long-form design in `docs/`, the plan links
to it and stays the operational document.

## Lifecycle

`draft` → `proposed` (owner decisions listed with defaults) → `decided` →
`in progress` (PROGRESS has rows) → `done` or `superseded by <link>`.

The header carries the status, the baseline commit the facts were measured
on, the owner and links to the companions. Dates: {{PLAN_DATES_POLICY}}.

## After implementation

Revise the plan in place rather than leaving it stale: "reflects the final
implemented state", a "Changes from v1" section, strikethrough with
"Superseded by" on items that no longer apply, a "Known mismatches still
open" list for what was deferred.

## Templates

| Template | Use |
| --- | --- |
| `_TEMPLATE.plan.md` | The plan |
| `_TEMPLATE.progress.md` | Per-PR log |
| `_TEMPLATE.handoff.md` | Taking over mid-work |
| `_TEMPLATE.kickoff.md` | Next session's first read |
| `_TEMPLATE.milestones.md` | Plain-language log |
