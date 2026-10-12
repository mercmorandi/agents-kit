# Verification

**Read this when:** before declaring any change done, and when the human
reports something broken.

## The local gate

For every backend or shared change: the test files of the touched area plus
the build of the affected workspaces.

```bash
make test-file FILE=<touched-test-file>
make build
make lint
```

The Makefile is the single entry point; the real per-side commands live
there, not in this document.

Do **not** run the full suite locally unless asked; continuous integration
runs it. A full local run interrupts other work and proves little more than
the touched area does. Choose test files by what the change exercises, not by
grepping for a symbol.

Run commands as single bare commands (no pipes, no `cd &&` chains) so the
permission allow-list matches them.

## Honest status

A test is **passed** only when it was run in this session and its output was
read. Anything not executed is **PENDING**, and the report says so. Never
infer a pass from "the code looks right" or from a previous session.

The report lists the exact commands run and their result. If a step was
skipped, say that it was skipped and why.

## Build is not verification

A green build, lint and type check prove the code compiles. They do not prove
the feature works. For anything with a user-visible surface:

- exercise the real entry point (the route, the command, the UI action), not
  only the unit;
- for UI, render it and look: column widths, truncated labels, overflow at
  the smallest supported width, dark mode if supported. If you could not
  render it, say so explicitly.

## Harness for slow manual validation

When a feature is validated by repeated manual entry (filling a form,
uploading a document, driving a flow), build a scriptable harness with a
fixed fixture before the second round. When the human tests through the UI,
hand them the complete fill-in dataset and an expected-results checklist.
Throwaway fixtures live in a gitignored `tmp/` folder.

## Validate against real samples

A clean sample proves the happy path. Before declaring an extractor, parser or
import "working", search for the real variants (older formats, missing
fields, other locales) and turn them into fixtures. When the human asks "are
you sure it works with this one?", the answer is a run, not a yes.

## Attribute regressions

When something breaks during the human's testing, establish with code
evidence whether the cause is **ours** (this change), **pre-existing**, or
**external** (a dependency, a service, an environment). Report which, and how
you know. "It should work" is not an attribution.

## Verify hypotheses, do not assume

When the human guesses a cause, check the code or the logs before agreeing.
Report the real mechanism even if it is a different cause than proposed. The
same applies to your own hypotheses.

## Constant provenance

Never present an inferred number (a limit, a dimension, a threshold, a rate)
as authoritative. State where it came from: a spec, a config, a designer, a
measurement you took. Do not derive a specification from rendering code or
from one sample. Mark domain constants you chose as `TO CONFIRM`.

## Test environment hygiene

The test setup explicitly neutralises the developer's local environment for
fail-closed dependencies (scanners, external auth, payment providers): a local
`.env` must not be able to change the whole suite's behaviour. Tests build
no implicit schema or indexes; a suite that depends on one builds it
explicitly. See `../rules/testing.md`.
