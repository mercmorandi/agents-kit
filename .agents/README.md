# `.agents/` — instructions for coding agents

Everything a coding agent needs to work on this repository that is not the
code itself. The entry point is the root `CLAUDE.md`; it tells the agent which
of these files to read for which task. Read this file when you need to decide
**where** a new piece of guidance belongs.

## Folders

| Folder | Contains | Written when |
| --- | --- | --- |
| `workflow/` | How the agent works: session loop, planning, implementation habits, verification gate, hand-off format, communication, safety. Project-agnostic. | Once, when the kit is adopted. Rarely edited. |
| `rules/` | Mandatory constraints by area of the system (architecture, API, errors, tests, security, docs). | When a constraint is decided. Edited when the constraint changes. |
| `patterns/` | Approved recipes to copy for one recurring task, each pointing at one canonical example in `src/`. | When the second occurrence of a task appears. |
| `plans/` | Per-feature specs and their companions: progress log, hand-off, next-session kickoff, plain-language milestones. | Before touching the area the plan covers. |
| `skills/` | Deep reference material loaded on demand (vendor or home-grown `SKILL.md` folders). | When a topic is too large for a rule and needed only sometimes. |

## Rule, pattern, plan or skill?

| You want to write down… | It is a… | Because |
| --- | --- | --- |
| "Never return a bare list from an endpoint" | **rule** | A constraint that always holds in one area. |
| "To add a list endpoint: copy `x.ts`, then …" | **pattern** | A repeatable recipe with a canonical file to copy. |
| "We are adding bookmarks; here is the API, the steps, the verification" | **plan** | Feature-scoped, has a lifecycle, ends. |
| "Everything about testing async services with this framework" (3 pages) | **skill** | Large, topic-scoped, needed only when the task matches. |
| "When you change the permission helper, also update the guards and this file" | **rule** (a checklist inside the rule for that area) | Keeps code and docs in sync. |
| "The agent must stop and ask before adding a dependency" | **workflow** | About how the agent behaves, not about this codebase. |

When in doubt: a rule is one page and says *what*; a pattern says *how* and
names *which file*; a plan says *what we are building now*; a skill says
*everything about one topic*.

## Reading order for an agent

1. Root `CLAUDE.md` (always).
2. `workflow/session-protocol.md` (always; it links the other workflow files).
3. The `rules/` files that `CLAUDE.md` routes to for the task.
4. The `patterns/` file for the task, if one exists.
5. The `plans/` file for the area, if one exists. If the plan has a
   `HANDOFF` or `KICKOFF` companion, read that first.
6. A skill only when its `description` matches the task.

## Document conventions

- Plain Markdown. No YAML frontmatter except in `SKILL.md`.
- Each rule, pattern and plan opens with a line `**Read this when:** …` so
  the `CLAUDE.md` routing can be rebuilt by hand.
- Code paths are backticked and relative to the repository root
  (`src/hooks/use-x.ts`), optionally followed by the symbol in parentheses.
- Links between documents are relative Markdown links, so they survive a move.
- `{{UPPER_SNAKE}}` marks a value to fill; `<!-- TODO(project): … -->` marks a
  section to write. Run `init.sh --check` to list what is still open.
- Prose in {{DOC_LANGUAGE}}. Code, identifiers and commit messages in English.
