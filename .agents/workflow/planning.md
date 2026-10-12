# Planning

**Read this when:** the task is larger than a local fix, introduces a new
flow, changes a data model, or will take more than one milestone.

## When a design document is required

Write a plan (template: `../plans/_TEMPLATE.plan.md`) before code when any of
these hold:

- more than one layer changes (schema + service + API + client);
- a cutover, migration or backfill is involved;
- the work will span several commits or sessions;
- a decision has alternatives with different costs the owner should see.

For the largest workstreams the design doc **is** milestone 0: context,
verified facts with `path:line`, decisions with the rejected alternatives,
flows, data model, API, client, cutover, milestones with gates, open
questions. Code starts only after it is agreed.

## Verified facts first

Before proposing, read the code and write down what is true today, with
file paths. A plan built on an assumption about the current behaviour is
wrong in proportion to that assumption. When a fact cannot be verified from
the code, mark it `UNVERIFIED` rather than stating it.

## Decisions

- Record each decision with the options considered, the one recommended and
  why, and once taken, the one decided. Mark it `Recommended` before and
  `Decided` after.
- Record the alternatives you rejected. A reader who does not see them will
  reopen them.
- Decisions the owner must take are listed in their own section with a
  default; the plan proceeds under the default and says so.

## Propose, do not survey

For a design choice, write a short proposal: the choice you recommend, the
reason, the trade-off you accept. Do not present a menu of options with no
preference, and do not block on a question you can answer with a reasonable
default stated explicitly.

## Explain before approval

Before asking for approval, walk through the reasoning and the end-to-end
flow: what happens from the user's action to the stored result and back.
Define the domain terms you use. The owner will ask "how did you think
this through"; have the answer written.

## Simplest mechanism

No refresh, TTL, cache, retry or sync layer for a case that does not exist.
Trace the mutability of the data first: if it never changes after creation,
no invalidation is needed. Name the trade-off you accept instead of building
for the case you imagined.

## Documents other readers will use

A plan, runbook or hand-off may be read by another agent or developer, out of
order, after a partial run. Guard against that explicitly:

- put blocking statements where a partial reading could cause harm ("do not
  run step 3 before the backfill in step 2 has been verified");
- put the glossary at the very top if abbreviations appear in the first
  section;
- make each step idempotent or say that it is not.

## Dates in plan documents

Policy: {{PLAN_DATES_POLICY}}. Status words (`draft`, `decided`, `in
progress`, `done`, `superseded`) describe state; the version history carries
the when.

## Scope skepticism

A net-new feature bundled with bug fixes gets its own approval bar. Separate
it in the plan: the fixes ship regardless; the feature needs its use cases
stated, not more architecture.

## Repeat-invocation legibility

For anything the user can run again (regenerate, retry, re-run, re-sync),
design versioning and a visible "what changed since last time" into the
first version. Discovering it during testing is too late.
