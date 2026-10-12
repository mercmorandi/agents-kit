# Pattern: Repository adapter

**Read this when:** persisting a new entity, or adding an adapter for an
external service, in a hexagonal service (`../rules/architecture-hexagonal.md`).

**Copy this when** adding a new repository or outbound adapter. Canonical
example: the **{{CANONICAL_ENTITY}}** entity.
Reproduce that exact shape unless the use case differs.

## The four files (one entity)

```
domain/entities/<entity>                         # business fields, incl. the external ref
        ↓  (domain knows nothing about persistence)
ports/outbound/<entity>_repository               # interface: the contract
        ↑  implemented by
adapters/outbound/repositories/<entity>_repository   # concrete, async, maps rows ↔ entities
        ↕
adapters/outbound/repositories/models/<entity>_model # persistence model / table
```

## Flow

1. **New file:** `src/domain/entities/<entity>` — plain object or dataclass.
   No ORM, no I/O. Holds the business fields including the external ref.
2. **New file:** `src/ports/outbound/<entity>_repository` — the interface
   declaring the async methods the domain or the use cases need
   (`get_by_ref`, `list_for_owner`, `create`, `update`, …). Accepts and
   returns **domain entities**, never models.
3. **New file:** `src/adapters/outbound/repositories/models/<entity>_model`
   — the table or document model. Inherits the base model (internal PK +
   external ref + timestamps).
4. **New file:** `src/adapters/outbound/repositories/<entity>_repository` —
   implements the port with the database session or client. The **only**
   module that imports the model. Maps model ↔ entity in two private
   functions.
5. Edit `src/api/v1/dependencies/repositories` — add the provider so
   entrypoints receive the port through injection.
6. Migration, if the persistence layer needs one
   (<!-- TODO(project): link the rule or doc where migrations are described -->).
7. Tests: port contract test against the real adapter (integration), use
   cases against a fake implementation of the port (unit).

## Rules

- **The model never leaks past the adapter.** Grep for its import outside
  `adapters/` before finishing.
- **Public surface uses the external ref**, never the internal PK.
- All methods are async if the stack is async; no sync call hidden in an
  async adapter.
- One repository per aggregate, not per table.
- Errors from the driver are translated at the adapter boundary into
  domain or application errors (`../rules/error-handling.md`); the driver's
  exception types do not cross the port.

## Example references (canonical, copy then adapt)

| Need | Reference file |
| --- | --- |
| Entity | <!-- TODO(project) --> `src/domain/entities/…` |
| Port | `src/ports/outbound/…` |
| Adapter | `src/adapters/outbound/repositories/…` |
| Model and base model | `src/adapters/outbound/repositories/models/…` |
| DI provider | `src/api/v1/dependencies/repositories…` |
| Fake port for unit tests | `tests/…` |

## Do / Do not

- Do: return `None` or an empty list for "not found" from the port and let
  the use case decide the error; or raise a domain `NotFound`, but pick one
  and keep it across repositories.
- Do: keep the mapping functions pure and tested.
- Do not: expose query-builder or session objects through the port.
- Do not: add a generic base repository "for later"; three concrete ones
  first.

## Scope discipline

- Apply only when the task adds an entity or an external integration.
- Do not retrofit existing adapters to a new base class as a side effect.
