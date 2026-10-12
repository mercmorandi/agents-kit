# Implementation habits

**Read this when:** writing or changing code.

## Copy the closest reference

Before writing a file in a layer, open the canonical example for that layer
(the table in `CLAUDE.md`, or the `Reference files` table of the matching
rule) and mirror it. If the exact case does not exist, copy the closest one
and adapt minimally. Do not introduce a new style, helper or abstraction when
the codebase already has one for the job.

## Scope discipline

- Implement only what was asked. No bonus features, no preventive
  abstractions, no "while we're here" cleanups.
- Do not refactor, rename, reorganise or reformat code outside the requested
  change. A pure rename, when it is the task, goes in its own commit.
- Never add a dependency, library or pattern without explicit approval.
- Never change formatter, linter, compiler or CI configuration as a side
  effect.
- Do not add tests, stories or documentation that were not requested, except
  what `verification.md` requires for the touched area.
- If something off-scope looks broken, report it with the evidence. Do not
  fix it silently.

## Root cause over band-aid

Fix the mechanism, not the symptom. Prefer:

- **explicit tracked state over heuristics**: a flag or a field that records
  the fact, not a regex or a string match that infers it;
- **denormalising a stable fact into a field** over recomputing it at every
  read;
- **hooking at the earliest point where the data exists** over patching every
  consumer downstream;
- **covering the abandoned and failed paths**, not only the happy one. Ask
  "what state is left if this stops halfway?" for every write.

## Verify the runtime surface before fixing

Confirm the exact entry point and code path that produces the behaviour
before changing it. A symptom that pattern-matches to a known cause may have
a different one. Build steps matter: a client change may need a rebuild
before it is visible; a server change may need a restart or a container
rebuild. Say which you did.

## Parity through required fields

When a fallback path must produce the same result as the primary path, make
the missing input **required** on the fallback, not optional with a default.
Optional-with-fallback hides the gap until production finds it.

## Bulk edits

Before a bulk rename or replace-all, grep for every occurrence and check the
locals and partial matches it will also hit (`Product.` also matches
`newProduct.save()`). After a model or symbol rename, sweep the adjacent
syntaxes that do not share the identifier: string references, lookups,
`ref:` fields, raw collection names, config keys.

## Chase the class, not the instance

When a bug turns out to be an instance of a class (a wrong model resolved, a
default flipped, a missing filter), audit every other site of that class in
the same change and report the result, even if the others were fine.

## Remove diagnostic scaffolding

Logging, counters, temporary flags and `console.log`s added while diagnosing
are removed in the same edit that fixes the bug, including the ones the human
added and asked you to keep "for now".

## Error handling and messages

Follow `../rules/error-handling.md`. Never swallow an exception to make a
feature appear to work. Every user-facing error has a message the user can
act on; every technical message has enough context to debug without reproducing.

## Comments and docs in code

Docblocks on public functions. `// TODO:` and `// FIXME:` for known
follow-ups, with what and why. A non-obvious decision gets a one-line
comment stating the reason, not a paragraph.
