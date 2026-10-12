# Skills

Deep, topic-scoped reference material the agent loads **on demand**, when the
task matches a skill's `description`. A skill is a folder with a `SKILL.md`
and optional `references/`, `assets/`, `scripts/`.

Skills live here, in `.agents/skills/`, and are exposed to Claude Code by a
symlink per skill:

```
.claude/skills/<name> -> ../../.agents/skills/<name>
```

`init.sh` creates the symlinks for every folder present. Keep the real files
here so the folder stays tool-agnostic and the link target stays one.

## Vendor skills

Install with the skills CLI, which writes a lock file next to the folder:

```bash
npx skills add <owner>/<repo>            # whole plugin
npx skills add <owner>/<repo> --skill x  # one skill
```

Do not edit a vendor skill in place; it is overwritten on update. Project
specifics go in a rule that references the skill ("apply skill X to all
Python written here; the rules below are the project-specific additions").

## Home-grown skills

Start from `_TEMPLATE/SKILL.md`. Write one when a topic is too large for a
rule (more than two screens), is needed only for some tasks, and would be
re-derived otherwise: the project's design system, a testing strategy for an
unusual architecture, an internal API's quirks.

### Frontmatter

```yaml
---
name: <kebab-case, same as the folder>
description: >
  What it covers and WHEN to use it, with the trigger words a task would
  contain. Two to four sentences. This is what the agent matches against.
paths:                 # optional: auto-load when the task touches these files
  - 'client/src/**'
user-invocable: false  # optional: hide from the slash-command list
---
```

`paths:` is the **only** auto-load mechanism; there is no hook. Everything
else is discovered through the `description` or through `CLAUDE.md`'s
"Skills (load when relevant)" list.

### Writing a description that triggers

- Name the topic and the artefacts ("tests, fixtures, mocks for FastAPI
  services").
- List the words a task would contain ("trigger when the user mentions
  'coverage', 'fixture', 'mock'").
- Say when **not** to use it if a sibling skill overlaps.

### Body

- "How to use" first: writing versus reviewing, how much to apply to a tiny
  snippet, whether to mention the skill to the human (usually: apply
  silently).
- A decision matrix or a checklist the agent can run on a draft.
- Canonical components or files, each heading a link to the source.
- Anti-patterns to fix on sight.
- Out of scope.

## Files

| Skill | Kind | Loads when |
| --- | --- | --- |
| `_TEMPLATE` | template | never; copy it |
| <!-- TODO(project) --> | | |
