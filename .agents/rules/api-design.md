# API design

**Read this when:** adding or changing an endpoint, its response or its
errors.

<!-- TODO(project): framework in bold, where routes live, how they are registered. -->

## Response envelope

Every JSON endpoint returns a wrapped body:

```
Success:    { "data": { … } }
Error:      { "error": { "message": "…", "code": "…", "details": { } } }
Paginated:  { "data": { "items": [ … ], "pagination": { "page", "limit", "total", "hasMore" } } }
```

Streaming responses are exempt. **Never return a bare list or a bare
object.** The client's error handling depends on the shape.

## Paginated lists — the standard

Any list endpoint that can grow without bound **must** paginate. Do not cap
silently with a fixed limit.

- Key is `items`, not a domain name.
- `page` and `limit` are parsed from the query and clamped inline in the
  handler: default `limit` {{PAGE_DEFAULT_LIMIT}}, maximum
  {{PAGE_MAX_LIMIT}}.
- The query runs the page and the count together; `hasMore = page * limit <
  total`.
- A list with dashboard counters adds a sibling `stats` object computed over
  the **whole filtered set**, since per-page counts misreport.
- The client table is in server-side mode: it renders the page as received,
  the server owns the order, the page resets to 1 on any filter change, and
  overlapping requests are guarded by a monotonic sequence.

Canonical example: <!-- TODO(project): `src/…` server side, `src/…` client hook, `src/…` table -->

## Errors

Error paths throw the most specific class from the shared error hierarchy and
let the global error handler emit the envelope. Never hand-roll a status and
body in a handler; never throw a bare generic error on an API path.

- Each class maps to one HTTP status
  (<!-- TODO(project): list them, e.g. Validation 400, Auth 401, Forbidden 403, NotFound 404, Conflict 409, …-->).
- Each error carries a **user message** in the product's language and a
  **technical message** in English.
- If no class fits a needed status, **add a subclass** to the hierarchy and
  export it. Never use a raw status code to work around the gap.

Hierarchy: <!-- TODO(project): `src/errors/…` --> · Handler: <!-- TODO(project) -->

## Validation

- Validate every input at the boundary with the project's schema library;
  the handler receives typed, validated data.
- Unknown fields are rejected or stripped by the validator, so a client
  field the schema does not declare **never reaches the service**. When a
  new field "does nothing", check the schema first.

## Authentication and authorisation

Every endpoint is behind the auth middleware and the permission check its
area requires. The guard is on the route, not inside the handler. See
`security.md`.

## When you add an endpoint

1. Copy the closest route module (see `Reference files`).
2. Declare the input schema; declare the response type.
3. Add the permission guard.
4. Register the router where its siblings are.
5. Add the test for the happy path and for each error class it can throw.
6. If the client calls it, add it to the API client module for that domain,
   never as an inline fetch.

## Do / Do not

- Do: return the envelope even for empty results.
- Do: paginate; add `stats` when the UI shows totals.
- Do not: cap a list with a fixed limit.
- Do not: `res.status(500).json(…)` in a handler.
- Do not: leak internal details in `message`; use `details` for structured
  context and keep it safe for the client.

## Reference files

| Need | Reference file |
| --- | --- |
| Route module with validation and guard | <!-- TODO(project) --> |
| Paginated list (server) | |
| Paginated list (client hook + table) | |
| Error hierarchy and handler | |

## Scope discipline

- Do not change the envelope or the pagination contract for one endpoint.
- Do not add a new auth mechanism; use the existing middleware.
