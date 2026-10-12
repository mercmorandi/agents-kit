# Architecture

**Read this when:** adding a file, a module or a dependency between modules.

<!-- TODO(project): one paragraph. The stack in bold, the top-level layout, the one-sentence architectural principle (e.g. "routes call services, services call repositories, nothing skips a layer"). -->

## Layout

```
<!-- TODO(project): the tree of top-level folders with a one-line purpose each -->
src/
├── api/         route handlers by domain
├── services/    business logic, one class per concern, dependencies injected
├── models/      persistence schemas and their interfaces
└── …
```

## Where new files go

| Need | Location | Mirror |
| --- | --- | --- |
| New endpoint | `src/api/<domain>/` | <!-- TODO(project) --> |
| New business rule | `src/services/<domain>/` | |
| New persisted entity | `src/models/` | |
| New shared type | | |
| New script | | |

## Dependency direction

- <!-- TODO(project): e.g. "api → services → models; never the reverse; shared packages import nothing from apps." -->
- Cross-cutting concerns (auth, tenancy, logging) enter through middleware or
  injection, never through a global imported from a leaf module.

## Service boundaries

<!-- TODO(project): if the system is split in several deployables, a table: service · port · purpose · what runs there. State the routing principle the client follows. -->

## Gotchas

<!-- TODO(project): the facts that caused a silent bug once. One short paragraph each, starting with the symptom. Example shape: "Two sibling models share a schema but not a collection: fetching through one and writing through the other matches nothing and raises no error." -->

## When you add a new module

1. Create it next to its siblings, with the same file layout.
2. Register it where its siblings are registered (router, DI container,
   index export).
3. Add its canonical file to the `Reference files` table of the matching
   rule if it is the first of its kind.

## Do / Do not

- Do: keep one responsibility per module; name it after the domain concept.
- Do not: reach across layers "just this once".
- Do not: add an internal HTTP call where a shared data layer already gives
  the data.

## Reference files

| Layer | Canonical file |
| --- | --- |
| Route module | <!-- TODO(project) --> |
| Service | |
| Model | |
| Middleware | |

## Scope discipline

- Do not move files between layers unless the task is that move.
- Do not introduce a new layer or a new top-level folder without approval.
