# Rules

Mandatory constraints, one file per area of the system. A rule says **what**
holds; a pattern (`../patterns/`) says **how** and **which file to copy**.

The files shipped here are stack-agnostic baselines with `{{SLOTS}}` and
`TODO(project)` sections. Edit them to the project; delete the ones that do
not apply and remove their line from the `CLAUDE.md` reading order.

## When to write a rule

- A constraint was decided and the agent must not re-derive it.
- Two sites already disagree on the same question.
- A bug came from an unstated assumption; write the assumption down where the
  next agent will read it, ideally with a one-line "this caused a silent bug"
  note.

## Skeleton (`_TEMPLATE.md`)

1. `# Title` and `**Read this when:** …` (the trigger used in `CLAUDE.md`).
2. One paragraph of purpose.
3. Topic sections: tables for "where things go", short imperative bullets,
   bold for the hard constraints.
4. Procedural checklists where a change must ripple ("When you add a new X: 1…
   2… 3…").
5. `## Do / Do not`.
6. `## Reference files`: need → path table. "Open and mirror the closest one
   before writing new code."
7. `## Scope discipline`: what not to do while working in this area.

Keep a rule to one screen or two. If it grows past that, the overflow is a
skill (`../skills/`) or a pattern.

## Files

| File | Area |
| --- | --- |
| `coding-standards.md` | Language and style baseline |
| `architecture.md` | Layered services: layers, where new files go, canonical references |
| `architecture-hexagonal.md` | Hexagonal services: rings, dependency rule, where new files go. Keep one of the two architecture files. |
| `api-design.md` | Response envelope, pagination standard, error classes |
| `error-handling.md` | Exceptions, messages, what never to do |
| `testing.md` | Tiers, layout, environment hygiene, definition of done |
| `security.md` | Input, authorisation, secrets, invariants with inventories |
| `documentation.md` | Where documents live and the shapes they take |
