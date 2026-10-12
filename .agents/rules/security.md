# Security

**Read this when:** handling input, files, credentials, permissions or
anything that reaches storage or a third party.

## Baseline

- **Validate and sanitise every input** at the boundary. Output that is
  rendered is escaped; output that is navigated to is restricted to safe
  schemes and in-app paths.
- **Every endpoint is authenticated and authorised.** The guard is on the
  route. A UI-only check is not a check: confirm the backend enforces the
  same rule.
- **Least privilege** for every credential, service account and token.
- **No secrets in code**, docs or logs. Configuration from the environment.
- **Fail closed.** A missing or unreachable guard refuses the operation; it
  does not wave it through. Local and test opt out explicitly with a named
  variable, never through an environment-name branch.

## Invariant + inventory

A security invariant is written as a sentence that is true everywhere, plus
the **complete inventory of its exceptions**, each with the reason it is
safe. Example shape:

> Every upload helper scans by default. `scanRequired` is passed `false` at
> exactly these call sites, for these reasons: (1) bytes we generated
> ourselves — `a.ts`, `b.ts`; (2) the same buffer was scanned a few lines
> above — `c.ts`. Anything new that bypasses the helper is outside the
> invariant by construction.

When you add an exception, add it to the inventory in the same change. When
the inventory is not in this file, say where it is.

<!-- TODO(project): the project's invariants, one subsection each. -->

## Files from outside

A file from a third party (a user, a partner API, an automation) is not
trusted because it arrived through a trusted channel. Scan or validate it
**before** anything parses it, and again when the stored copy is written if
the two steps are separated. Nothing serves bytes straight from a staging
area.

## Multi-tenancy

<!-- TODO(project): if applicable. How isolation is enforced (plugin, schema, database), that it is fail-closed, and the one gotcha that caused a silent leak or no-op. -->

## Permissions checklist

When permission logic changes:

1. Update the permission helper.
2. Update this file and the permission matrix it points to.
3. Update every guard that uses the helper; grep for its name.
4. Confirm the backend enforces the same rule.

## Do / Do not

- Do: restrict links to in-app paths or `https://`.
- Do: clip and sanitise machine-emitted content before storing it.
- Do not: build a query from string concatenation of user input.
- Do not: log request bodies that may contain credentials or personal data.
- Do not: add an environment check that disables a guard.

## Reference files

| Need | Reference file |
| --- | --- |
| Auth middleware | <!-- TODO(project) --> |
| Permission helper and guards | |
| Input sanitiser | |
| Upload path with scan | |

## Scope discipline

- Do not loosen an invariant to make a feature pass; stop and ask.
- Do not touch IAM, network or ingress configuration unless the task is
  that configuration.
