# Documentation

**Read this when:** writing or updating any document: a plan, a rule, a
hand-off, a runbook, a milestones log, `CLAUDE.md`.

## Where documents live

| Kind | Location |
| --- | --- |
| Agent instructions, rules, patterns | `.agents/` |
| Feature plans and their companions | `.agents/plans/<feature>/` or `docs/<feature>/` <!-- TODO(project): choose one --> |
| Architecture and long-form design | `docs/` |
| Runbooks and environment recipes | `docs/` or `CLAUDE.md` when the agent needs them every session |
| Throwaway census and investigation output | gitignored `tmp/<topic>/` |

## Shapes

- **Plan**: `../plans/_TEMPLATE.plan.md`. Header with status and baseline,
  glossary at the top if needed, TL;DR, scope, inventory, decisions, sequence
  with gates, verification, risks and rollback, out of scope, how this was
  measured.
- **Progress**: `../plans/_TEMPLATE.progress.md`, updated in every PR.
- **Hand-off** and **kickoff**: `../plans/_TEMPLATE.handoff.md`,
  `../plans/_TEMPLATE.kickoff.md`.
- **Milestones log**: `../plans/_TEMPLATE.milestones.md`, plain language, no
  code.
- **Rule**, **pattern**: `../rules/_TEMPLATE.md`, `../patterns/_TEMPLATE.md`.

## Status markers

`draft` · `proposed` · `decided` · `in progress` · `done` · `on hold` ·
`superseded by <link>`. One marker per document in the header; per item
inside tables (`TO DO`, `DONE`, `DEFERRED`, `DECIDED`).

Dates: {{PLAN_DATES_POLICY}}.

## Conventions

- Glossary **at the very top** if abbreviations appear in the first section.
- Code paths backticked, relative to the repository root, with the symbol in
  parentheses when useful.
- Decisions recorded with the options considered and the alternatives
  rejected.
- "How this was measured" closes any document that states counts or
  inventories: the commands or scripts, the baseline commit, the control
  check.
- A document another reader may execute partially carries its blocking
  statements where the partial reading happens.
- Documents revised after implementation say so: "reflects the final
  implemented state", a "Changes from v1" section, strikethrough with
  "Superseded by" on items that no longer apply.

## Keeping `CLAUDE.md` current

`CLAUDE.md` holds what the agent needs **every session**: commands, layout,
reading order, canonical references, hard rules, gotchas, diagnostic
scripts. When a change adds one of these, update `CLAUDE.md` in the same
hand-off:

- a new model, index or migration mechanism → the "when you change X also
  bump Y" line;
- a new diagnostic script → when to use it, how to call it, how to read its
  output, including known false positives;
- a silent bug → a "Gotcha" paragraph starting with the symptom;
- a new tool, chip, enum or registry entry → the checklist of every place it
  must be registered, including translations.

## Do / Do not

- Do: write for a reader who did not watch the work.
- Do: say what is NOT done.
- Do not: describe the full correct sequence and assume it will be followed
  in order; guard the steps.
- Do not: put document content in `CLAUDE.md` that the agent needs only for
  one feature; link the plan instead.

## Reference files

| Need | Reference |
| --- | --- |
| A good plan in this repo | <!-- TODO(project) --> |
| A good hand-off | |

## Scope discipline

- Do not rewrite a document's structure while updating one section.
- Do not delete history from a progress file; mark it superseded.
