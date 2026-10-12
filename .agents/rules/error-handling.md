# Error handling

**Read this when:** writing anything that can fail: I/O, network, parsing,
external calls, concurrency.

## Rules

- **Do not swallow exceptions.** A `catch` that logs and continues needs a
  comment saying why continuing is correct.
- **Use the most specific error type available.** Generic errors hide the
  cause from both the handler and the reader.
- **Never silence an existing error to make a feature appear to work.**
- Every error that can reach a user has a message the user can act on, in
  the product's language. Every error has a technical message with enough
  context (identifiers, step, input shape, never secrets) to debug without
  reproducing.
- An error on an API path follows `api-design.md`: throw the class, let the
  handler emit the envelope.

## Failure paths are part of the feature

For every write, ask what state is left if the process stops halfway, and
cover it: a job marked `failed` with the reason, a partial upload cleaned up,
a retry that is idempotent. The abandoned path (the user closes the tab, the
task times out) is designed, not discovered.

## Verdicts are a contract

When a guard produces a verdict (a scan, a validation, a check), the mapping
from verdict to outcome lives in **one place** and is fail-closed: a verdict
that cannot be parsed is an error, never read as success. Collapsing failures
into `null` is acceptable only for the storage step, never for the verdict.

## External calls

- Timeouts on every call; a bound stated in configuration, not a magic number.
- Rate limits and quota errors are distinguished from other failures and
  retried only where the operation is idempotent.
- Partial results from a batch are reported as partial, with which items
  failed.

## Logging

- Log at the boundary where the error is handled, once, with context. Do not
  log the same error at every layer it passes through.
- No personal data or secrets in logs.

## Do / Do not

- Do: fail fast at the boundary with a validation error.
- Do: name the error class after the condition, not after the HTTP status.
- Do not: `catch (e) {}`.
- Do not: return `null` to mean "something went wrong".
- Do not: wrap an error in a generic one and lose the original.

## Reference files

| Need | Reference file |
| --- | --- |
| Error hierarchy | <!-- TODO(project) --> |
| Global error handler | |
| Async handler wrapper | |
| A service that handles a partial failure well | |

## Scope discipline

- Do not add a new logging library or error-tracking integration without
  approval.
- Do not change the error envelope; see `api-design.md`.
