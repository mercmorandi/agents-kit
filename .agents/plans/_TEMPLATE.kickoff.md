# {{Feature}} — next session kickoff

> **Read this first.** Rewritten by the owner at each iteration.

## 0. Where we are

| Phase | State |
| --- | --- |
| M1 | done |
| M2 | in progress — … |
| M3 | not started |

## 1. Goal of this session

One paragraph. Alternatives to agree on before starting, if any.

## 2. Required reading, in this order

1. Last hand-off: [HANDOFF](HANDOFF.md)
2. [PLAN](PLAN.md) — the source of truth
3. [PROGRESS](PROGRESS.md)
4. If you touch code: root `CLAUDE.md`, then the rules it routes to.

## 3. Non-negotiable constraints

- **Commits:** {{AGENT_COMMITS}}. No push, no PR, no deploy.
- **Environments:** {{ENVIRONMENTS}}.
- **Do not declare a test passed that was not run in this session.**
- **No breaking changes** to <surface> — it is in production.
- Before substantial changes: a short report (verified local state + the
  first block you propose), then confirmation.
- At session end: hand-off + this kickoff updated + suggested commit.

## 4. What was NOT done last time

- …

## 5. Scope of this session

In: … Out: …

## 6. Environment state

Services to start, variables to set (names only), data present locally.

## 7. Suggested opening prompt

```
Read .agents/plans/{{feature}}/KICKOFF.md and the documents it lists, in
order. Report the verified local state and the first block you propose,
then wait for confirmation.
```
