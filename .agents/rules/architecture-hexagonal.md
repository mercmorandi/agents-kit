# Architecture — hexagonal (ports and adapters)

**Read this when:** adding or moving any file in a service built as
hexagonal architecture. Use this file **instead of** `architecture.md`; keep
one of the two and remove the other from the `CLAUDE.md` reading order.

<!-- TODO(project): framework in bold, the service(s) this applies to, link to the long-form design doc if one exists. -->

## The rings

```
API / entrypoints  →  Adapters (infrastructure)  →  Ports (interfaces)  →  Domain (pure logic)
```

- **Domain** (`src/domain/`): entities, value objects, domain services. Pure
  language, **zero** framework or I/O imports. Never imports from `ports`,
  `adapters` or `api`.
- **Ports** (`src/ports/`): abstract interfaces describing what the domain
  needs from the outside (`outbound`: repositories, storage, external
  services) and what the outside may ask of it (`inbound`: use cases). No
  concrete implementations.
- **Adapters** (`src/adapters/`): concrete implementations of ports: database
  repositories, object storage, auth provider, job queue, message bus. Wired
  at startup through dependency injection.
- **API / entrypoints** (`src/api/`, jobs, CLI): thin. Compose adapters, call
  domain logic or use cases, map to transport schemas. No business logic.

**The dependency rule is one-way: inner rings never import outer rings.** If
the domain seems to need an adapter, you need a new port instead. If a route
handler is growing business logic, you need a use case instead.

## Where new files go

| You are adding… | Put it in… | Pattern |
| --- | --- | --- |
| A business entity or value object | `src/domain/entities/<name>` | — |
| A domain service (logic across entities) | `src/domain/services/<name>` | — |
| An outbound contract (what we need from outside) | `src/ports/outbound/<name>_repository` (interface) | `../patterns/repository-adapter-pattern.md` |
| A repository implementation | `src/adapters/outbound/repositories/<name>_repository` | same |
| A persistence model / table | `src/adapters/outbound/repositories/models/<name>_model` | same |
| An external-service adapter (storage, LLM, mail) | `src/adapters/outbound/<service>/` | same shape as a repository |
| A use case | `src/application/use_cases/<verb>_<noun>` <!-- TODO(project): or omit the layer if handlers call ports directly --> | — |
| A REST resource | `src/api/v1/routes/<name>/` | `../patterns/entrypoint-module-pattern.md` |
| A DI provider | `src/api/v1/dependencies/` | — |

<!-- TODO(project): adjust folder names to the real tree; keep the ring each one belongs to. -->

## Identifiers

Two identifiers per entity:

- an **internal primary key** (serial or native id), never exposed over the API;
- an **external reference** (UUID or opaque id), called **{{EXTERNAL_ID_NAME}}**
  everywhere, used in URLs, payloads and logs.

Never leak the internal key; never accept it as input.

## Ports return domain objects

A port's methods accept and return **domain entities**, never persistence
models or transport schemas. Mapping happens in the adapter (model ↔ entity)
and in the entrypoint (entity ↔ schema). A model that crosses the port is
the most common violation; grep for model imports outside `adapters/`.

## Wiring

Adapters are constructed once at startup and injected: the entrypoint
receives the port type, the container decides the implementation. Tests
swap the implementation without touching the entrypoint. No global
singletons imported from leaf modules.

## When you add an entity end to end

1. Domain entity.
2. Outbound port.
3. Adapter + model (`repository-adapter-pattern.md`).
4. DI provider.
5. Entrypoint module (`entrypoint-module-pattern.md`).
6. Tests per ring (`testing.md`, "Test per ring").

## Do / Do not

- Do: keep the domain importable with no framework installed.
- Do: name ports after the capability (`ConversationRepository`,
  `DocumentStorage`), adapters after the technology
  (`PostgresConversationRepository`, `GcsDocumentStorage`).
- Do not: import a model, a client or a framework type into `domain/`.
- Do not: put a query or an HTTP call in a route handler.
- Do not: add a port with a single method that mirrors one adapter call;
  ports describe what the domain needs, not how the vendor works.

## Reference files

| Ring / need | Canonical file |
| --- | --- |
| Domain entity | <!-- TODO(project) --> `src/domain/entities/…` |
| Outbound port | `src/ports/outbound/…` |
| Repository adapter + model | `src/adapters/outbound/repositories/…` |
| Use case | `src/application/use_cases/…` |
| Entrypoint module | `src/api/v1/routes/…/` |
| DI providers | `src/api/v1/dependencies/…` |

## Scope discipline

- Do not move files between rings unless the task is that move.
- Do not introduce a new ring, a shortcut between rings, or a shared
  "utils" that imports from two rings.
