# Session protocol

**Read this when:** always, at the start of every task. It links every other
workflow file.

This repository is worked on by humans and coding agents. The reviewer expects
code that looks written by the same hand as the rest of the project, delivered
in verifiable steps, with an honest account of what was and was not done.

## The loop for every task

1. **Read.** The root `CLAUDE.md`, then the `.agents/rules/` and
   `.agents/patterns/` files it routes to for this task, then the
   `.agents/plans/` file for the area if one exists. If a plan has a
   `HANDOFF` or `KICKOFF` companion, read that first: it says what was decided
   and must not be reopened.
2. **Mirror.** Open the canonical reference for the layer you are touching
   (the table in `CLAUDE.md`) and read it before writing anything. Reproduce
   its shape. Do not invent a new approach when one exists.
3. **Plan.** Decide the smallest change that satisfies the request. For
   anything larger than a local fix, follow `planning.md`: write the design
   down, propose, get confirmation.
4. **Implement** minimally, following `implementation.md`. No speculative
   abstractions, no unrequested initiative.
5. **Verify** with `verification.md`: run the local gate for the touched area,
   check the runtime surface, state exactly what was run.
6. **Hand off** with `handoff.md`: a plain-words explanation of what the
   milestone does (a few lines, no code), the staged files, the suggested
   commit, the milestone log entry, what is NOT done.
7. **Stop.** Milestone cadence: {{MILESTONE_CADENCE}}. Do not start the next
   milestone unprompted unless the human has said to chain.

## Stop and ask when

- A rule in `.agents/rules/` cannot be satisfied by the requested change.
- The change needs a new dependency, library, abstraction or design pattern.
- The change would touch tooling config (formatter, linter, compiler, CI) and
  the task is not about that config.
- Two readings of the request lead to materially different work.
- A command would have side effects outside the working tree (see `safety.md`).
- A customer-visible formula, limit or domain constant must be chosen and no
  source states it (see `communication.md`, "Unconfirmed constants").

Ask with a proposal attached: "I would do X because Y; alternative Z costs W."
Never ask a question whose answer you could get from the code.

## No unrequested initiative

Only do what was asked. If a refactor, an extra test, a rename or a cleanup
"would be nice", mention it in the final report and leave the code alone.
If something off-scope looks broken, say so with the evidence; do not fix it
silently. See "Scope discipline" in `implementation.md`.

## When in doubt

Prefer re-reading the `.agents/` documents and the canonical references over
guessing. Consistency with existing patterns matters more than cleverness.
If the human remembers a behaviour differently from what you believe, verify
(git history, the actual wiring) before contradicting them.

## Definition of done for a task

- The requested behaviour works on the real entry point, not only in a unit.
- The local gate for the touched area passes, and the report says which
  commands ran.
- No diagnostic scaffolding is left behind.
- Documents that the change makes stale are updated in the same hand-off
  (rules, patterns, the plan's PROGRESS, the milestones log).
- The hand-off lists what was deliberately left out.
