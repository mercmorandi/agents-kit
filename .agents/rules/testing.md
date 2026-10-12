# Testing

**Read this when:** adding or changing tests, or deciding which tests to run.

<!-- TODO(project): framework in bold, runner config path, where tests live. -->

## Tiers

| Tier | Location | Dependencies | Runs in |
| --- | --- | --- | --- |
| Unit | <!-- TODO(project): e.g. `src/__tests__/unit/**` --> | mocked | local gate, CI |
| Integration | <!-- TODO(project): e.g. `src/**/*.test.ts` --> | real local services (in-memory DB, containers) | CI; locally for the touched area |
| End-to-end | <!-- TODO(project) --> | running app | CI, on request |

Every test declares its tier (marker, folder or file suffix, as the runner
expects); the runner rejects undeclared ones. Test files mirror the layout
of the code they test.

## Commands

```bash
make test                      # all
make test-file FILE=<path>     # one file, path relative to the side's folder
```

## What to run locally

The touched area's test files plus the build. The full suite is CI's job.
Pick the files by what the change exercises. See
`../workflow/verification.md`.

## Environment hygiene

The test setup is explicit about the environment it runs in:

- It loads the local environment file, then fills missing variables with
  dummies so CI, which has no such file, does not fail at import time.
- It **neutralises** fail-closed dependencies (scanners, external auth,
  payment providers) by setting their opt-out variable unconditionally and
  blanking their endpoint, so a developer's local file cannot change the
  whole suite.
- It pins any provider switch (auth provider, feature flag) to one value.
- It builds **no implicit schema or indexes**, as production does not. A
  suite that depends on an index or a constraint builds it explicitly in its
  setup.

Setup files: <!-- TODO(project): `jest.setup.ts`, `conftest.py`, … -->

## Test per ring (hexagonal services)

If the service follows `architecture-hexagonal.md`, each ring has its own
tier and its own mocking rule:

| Ring | Tier | Mocks | Shape |
| --- | --- | --- | --- |
| Domain | unit | none | plain assertions on entities and domain services; the fastest tests |
| Use cases / application | unit | **every port**, with fakes or mocks | inject fake ports, assert on the result and on the calls made |
| Adapters | integration | none: real local infrastructure | contract test of the port against the real database, storage or queue |
| Entrypoints | integration | only true external calls (LLM, identity provider) | the real app over HTTP; assert on status and envelope |

Coverage order when starting from nothing: domain first, then use cases,
then entrypoints, adapters last.

## Fixtures and factories

- Fixtures are small, named after what they represent, and built by
  factories with sensible defaults and explicit overrides.
- Real-world variants (older formats, missing fields, other locales) become
  fixtures the first time they are found; a clean sample is not enough.
- Throwaway fixtures for manual harnesses live in a gitignored `tmp/`.

## Definition of done for a change

- New behaviour has a test at the lowest tier that can observe it.
- Each error class a handler can throw has a test.
- A bug fix adds the test that would have caught it.
- UI changes: rendered and looked at (see `../workflow/verification.md`);
  component tests only if the task asks.

## Do / Do not

- Do: assert on the envelope and the status, not on internal calls, for API
  tests.
- Do: use the shared assertion helpers (<!-- TODO(project) -->).
- Do not: write tests that were not requested, beyond the definition of done.
- Do not: mock the layer under test.
- Do not: depend on test order or on leftovers from another test.

## Reference files

| Need | Reference file |
| --- | --- |
| Unit test with mocked dependencies | <!-- TODO(project) --> |
| Integration test with a real local database | |
| API test asserting the envelope | |
| Factory | |

## Scope discipline

- Do not change runner configuration or thresholds as a side effect.
- Do not add a second test framework.
