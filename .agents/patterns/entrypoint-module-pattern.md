# Pattern: Entrypoint module (REST resource)

**Read this when:** adding a new REST resource to a hexagonal service.
Pairs with `../rules/api-design.md` and `../rules/architecture-hexagonal.md`.

**Copy this when** adding a resource end to end. Canonical examples: the
**{{CANONICAL_RESOURCE}}** module.
Reproduce that exact shape unless the use case differs.

## The package (three files)

```
src/api/v1/routes/<resource>/
  __init__
  routes       # router + path declarations ONLY (no logic)
  handlers     # the logic; functions called by routes; talk to ports / use cases
  schemas      # transport models: *Request / *Response / *ListResponse
```

## Flow

1. **New folder** `src/api/v1/routes/<resource>/` copied from the canonical
   module.
2. `routes` builds the router with prefix and tags, declares each path,
   gates it with the permission dependency (`../rules/security.md`),
   injects ports through the DI providers, and delegates straight to
   `handlers`. Nothing else.
3. `handlers` holds the logic: validate the business preconditions, call
   the port or the use case, map entities to response schemas, raise the
   error classes.
4. `schemas` defines request and response models. **Wrap collections** in a
   `*ListResponse` with the pagination block; never return a bare list
   (`../rules/api-design.md`).
5. Register the router in the aggregator (`src/api/v1/__init__` or
   equivalent). The application entrypoint mounts the aggregate once; no
   change there.
6. If the resource needs a new port, add the provider in
   `src/api/v1/dependencies/`.
7. Test: endpoint test under `tests/integration/api/` with the real app and
   only true external calls mocked; one case per error class.

## Rules

- **No business logic in `routes`.** A conditional there is a smell.
- **Every path has an auth or permission dependency**; the default is
  denied.
- Handlers never import a model or a driver; they see ports and entities.
- Response schemas are built from entities, never from models.

## Example references (canonical, copy then adapt)

| Need | Reference file |
| --- | --- |
| Routes file | <!-- TODO(project) --> `src/api/v1/routes/…/routes` |
| Handlers file | `src/api/v1/routes/…/handlers` |
| Schemas with a `*ListResponse` | `src/api/v1/routes/…/schemas` |
| Router aggregator | `src/api/v1/__init__` |
| Auth dependencies | `src/api/v1/dependencies/auth` |
| Endpoint test | `tests/integration/api/…` |

## Do / Do not

- Do: keep the three-file split even for a tiny resource.
- Do: name handlers after the use case (`create_conversation`), not after
  the HTTP verb.
- Do not: put a query in a handler.
- Do not: return a bare list or a bare entity.

## Scope discipline

- Apply only when the task adds a resource.
- Do not split or merge existing modules to match this shape unless asked.
