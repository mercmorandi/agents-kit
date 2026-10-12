# Hand-off

**Read this when:** a milestone is verified and ready to be committed, or a
session is ending.

## Commit ownership

Policy: **{{AGENT_COMMITS}}**.

- `never`: the agent stages nothing and commits nothing. It hands over the
  file list and a suggested commit message; the human commits.
- `on request`: the agent commits only when told to, one commit per hand-off
  item below.
- `always`: the agent commits each verified milestone on its own branch.

Whatever the policy, the agent never pushes, never opens a pull request and
never touches the remote unless `safety.md` says otherwise.

## Shape of a commit

- Title: hard maximum **{{COMMIT_TITLE_MAX}}** characters, in the form
  `type(scope): what changes`, product effect first
  (`feat(auth): expire invites after 7 days`).
- Body: wrapped at ~75 columns, says why and what the reviewer should look at.
- **One commit per logical task.** A pure rename is separate from content
  changes. A feature spanning layers gets one commit per layer, in dependency
  order (schema → service → API → client).
- No ticket codes, design-tool links or internal nicknames in the title.

## The hand-off message

Written in {{CHAT_LANGUAGE}}, in this order:

1. **In plain words**: what this milestone does, explained simply to someone
   who does not read code. A few lines, no file names, no identifiers: the
   problem it solves and what changes for the user. This paragraph is
   mandatory every time a commit is handed over, and it is the same text
   appended to the milestones log.
2. **Outcome** in one or two sentences: what works now, verified how.
3. **Files**, grouped by commit, as a table: `path | what changed | commit`.
   When the list is larger than the request sounded, split it into
   **required** (the request) and **opportunistic** (what you touched on the
   way and why) before the human asks.
4. **Suggested commit(s)**: title and body in a fenced block, plus the
   `git add` block, with the note "run from repo root".
5. **Verification actually run**: the commands and their results.
6. **NOT done**: what was left out, deferred or found broken off-scope.
7. **Next**: the next milestone, as a proposal, without starting it.

## Pull request description

In {{CODE_LANGUAGE}}, no hard line wraps, sections: **Why** · **What
changed** (by area) · **Verification** · **Deploy notes** (env vars, data
steps, order). Screenshot slots as captioned blocks, not tables. The
description lists every deleted file.

## Changelog

User-facing, in the product's language, under: **New** · **Changed
behaviour** · **Security** · **Out of scope**. Written from the milestones
log, not from the diff.

## Documents updated in the same hand-off

- The plan's `PROGRESS` file: one row per change (what · outcome · why ·
  verification · PR).
- The plain-language milestones log (`../plans/_TEMPLATE.milestones.md`): one
  entry per milestone, no code, in {{DOC_LANGUAGE}}, so the changelog and a
  non-developer can follow the path.
- Any rule or pattern the change made stale.
- Append the entries in the same turn as the hand-off and include them in the
  staged files.

## Ending a session

When the work continues in another session, write two documents from the
templates in `../plans/`:

- a **HANDOFF** addressed to whoever takes over: read-first list in order,
  decisions not to reopen, done-when checklist, what is NOT done,
  verification actually run, suggested commit, local state to know about;
- a **KICKOFF** for the next session: where we are, the goal, required
  reading, non-negotiable constraints, scope, environment state, a suggested
  opening prompt.

Scrub both of secrets, personal identifiers and absolute paths.
