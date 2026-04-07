---
name: surrealdb
description: Build, query, model, secure, and operate SurrealDB 3 systems with current v3 guidance. Covers SurrealQL, graph and document patterns, vector and full-text search, auth and capabilities, deployment, migration, and practical v3 caveats.
---

# SurrealDB 3

Use this skill for SurrealDB 3 architecture, schema design, querying, migration, security, and operations work.

## Version Notes

- **Compiled for SurrealDB v3.0.5**.
- **Verified on 2026-04-07** against official SurrealDB docs, release notes, and launch blog.
- When docs and older examples disagree, prefer the latest **v3 release notes** and current **official docs**.

## What SurrealDB 3 Is Good At

SurrealDB is a multi-model database with one query language, **SurrealQL**, across:

- documents
- graph relationships
- relational-style references
- full-text search
- vector search
- time-series data
- geospatial data
- key-value style access

It can be used as:

- an embedded database
- a single-node server
- a persistent local datastore
- part of a distributed deployment

It exposes multiple access surfaces:

- SurrealQL
- HTTP
- RPC / WebSocket
- GraphQL
- CBOR-oriented integrations
- official SDKs

## Core v3 Mental Model

Design around these ideas first:

1. **One engine, mixed models**: keep documents, relations, search, and vectors in one system when that reduces sync work and cross-store complexity.
2. **SurrealQL is the center**: schema, auth, relations, queries, indexes, and APIs all converge there.
3. **Graph is native**: use `RELATE`, edge tables, and traversal operators instead of reconstructing graphs in application code.
4. **Security is part of schema design**: table permissions, access methods, and runtime session/auth context matter early.
5. **v3 is not just v2 plus patches**: it changed core semantics, indexing, extensions, APIs, and operational defaults.

## What Changed in SurrealDB 3

These are the big v3 shifts worth keeping in working memory:

- **Computed fields replaced older future-style patterns.** Treat computed fields as derived values, not stored columns.
- **Values and expressions were separated internally.** That matters because many v3 query and type behaviors became stricter and more predictable.
- **Synced writes are the default.** Durability behavior is stricter than older assumptions from earlier versions.
- **GraphQL is now a serious first-class surface.** v3 stabilized GraphQL support, and later 3.0.x releases added subscriptions.
- **`DEFINE API` is production-relevant in v3.** You can define custom API endpoints inside the database model instead of pushing every thin endpoint into app code.
- **Client-side transactions were added.** Applications can open a transaction, perform multiple operations, then commit or cancel explicitly.
- **Record references improved.** v3 added stronger reference and reverse-traversal patterns, including reverse lookup syntax.
- **Indexing and the planner changed substantially.** v3 added a new planner/executor path, better compound scans, `COUNT` indexes, better full-text concurrency, and stronger vector indexing.
- **Surrealism arrived.** v3 added the WASM-based extension path for custom in-database logic.
- **M-Tree was removed in favor of HNSW-oriented vector work.** Do not design new v3 vector systems around old MTree assumptions.

## Practical Quick Start

Use local defaults only for local development.

```bash
# In-memory development only
surreal start memory --user root --pass root --bind 127.0.0.1:8000

# Persistent RocksDB
surreal start rocksdb://data/app.db --user root --pass root

# Persistent SurrealKV
surreal start surrealkv://data/app --user root --pass root

# Open a SQL REPL
surreal sql --endpoint http://127.0.0.1:8000 --user root --pass root --ns app --db app

# Check installed version
surreal version

# Upgrade the binary
surreal upgrade
```

For production, do not keep `root/root`, and do not start from an allow-everything security posture.

## Recommended Modeling Strategy

Use the smallest model mix that solves the problem cleanly.

### Prefer plain records when

- data is mostly aggregate-owned
- reads are record-centric
- joins/traversals are shallow
- schema evolution speed matters more than strict relational modeling

### Prefer relation tables when

- the connection itself has properties
- you need directional traversal
- you need to filter or aggregate over edges
- the relationship is important enough to deserve its own schema

### Prefer record references when

- you want direct links without always materializing edge records
- reverse traversal matters
- the domain is more “linked documents” than “edge-first graph”

### Prefer computed fields when

- the value is derived from other fields
- you want consistent derivation close to the data
- you do **not** want to persist duplicated state

Important computed-field constraints in v3:

- do not define them on the `id` field
- do not define them on nested fields
- do not plan on indexing them
- combine `DEFAULT`, `VALUE`, and `ASSERT` only in ways current docs allow

## Graph and Relationship Patterns

SurrealDB’s graph features are strong enough that you should use them directly instead of simulating them with application joins.

Key tools:

- `RELATE`
- `TYPE RELATION`
- `->` outgoing traversal
- `<-` incoming traversal
- `<->` bidirectional traversal
- `<~` reverse reference lookup

Use **edge tables** when the relationship has meaning.

Example domains that benefit immediately:

- social graphs
- permissions graphs
- organization hierarchies
- knowledge graphs
- recommendations
- dependency maps

Rule of thumb:

- if the edge has attributes, lifecycle, or policies, model it explicitly
- if the link is simple and mostly navigational, record references may be enough

## Querying in v3

Expect to use these features heavily:

- `SELECT`, `CREATE`, `UPDATE`, `UPSERT`, `DELETE`, `INSERT`
- `RELATE`
- schema definitions with `DEFINE`
- `INFO FOR ...`
- transactions
- subqueries
- `FETCH`
- live queries
- graph traversal inside normal queries

Two practical v3 notes:

- `INFO FOR` can be used as a subquery in v3-era workflows.
- The planner and executor are much more capable than older SurrealDB examples imply, so re-check old advice before copying it.

## Live Query Guidance

Use `LIVE SELECT` when you genuinely need server-pushed change notifications.

v3 matters here because it improved live-query protocol behavior and tooling:

- live and kill responses expose more explicit query-type metadata
- killed live-query notifications were added
- RPC live statement options improved
- later 3.0.x work continued improving live-query correctness

Design guidance:

- use live queries for dashboards, collaborative UX, and push-driven updates
- keep filters narrow
- verify permission behavior, especially for delete events and role changes
- prefer explicit event handling in the client instead of assuming opaque stream semantics

## Search and Indexing

Treat v3 indexing as one of the major reasons to upgrade.

### Index types you should think about

- standard indexes
- unique indexes
- compound indexes
- `COUNT` indexes
- full-text indexes
- vector indexes

### Full-text search

v3 full-text search is materially stronger than older SurrealDB examples suggest.

Important points:

- full-text indexes use analyzers
- `search::score()` and related search functions matter for ranking and highlighting
- boolean `OR` support improved in v3
- full-text indexing gained stronger concurrency behavior

Use full-text search when:

- keywords matter
- explainability matters
- ranking should follow textual relevance rather than embedding similarity

### Vector search

SurrealDB 3 supports vector search directly in the database.

Use it for:

- semantic search
- RAG retrieval
- similarity lookups
- recommendations
- hybrid keyword + semantic ranking

Practical v3 guidance:

- use **HNSW** for approximate nearest-neighbor search at scale
- use brute-force comparison when exactness or small corpus size matters more than index complexity
- vector workflows pair well with metadata filtering and graph traversal
- v3 removed the old MTree direction; plan around HNSW instead

The official docs and guides describe vector workflows with distance metrics such as:

- cosine
- euclidean
- manhattan
- minkowski

### Deferred index maintenance

`DEFER` exists for background index building and maintenance when eventual consistency is acceptable.

Do **not** pair `DEFER` with `UNIQUE`.

### Performance-relevant v3 index changes

v3 added or improved:

- compound prefix + range scans
- descending index scans
- better `ORDER BY` handling with indexes
- `LIMIT`-aware scans
- concurrent index building
- concurrent HNSW writes
- numeric key normalization for more consistent index behavior
- bounded HNSW vector cache behavior

## Security and Access Control

Design security as a database concern, not just an application concern.

Core tools:

- `DEFINE USER`
- `DEFINE ACCESS`
- table permissions
- namespace and database scoping
- `$auth`
- `$session`
- session functions

What to do in practice:

- define least-privilege access methods early
- enforce row-level permissions in schema
- distinguish system users from record/user-facing auth flows
- test permissions with realistic session contexts

### Capabilities

SurrealDB has an explicit capabilities model for things like outbound network access and function families.

In production, start from **deny by default**.

Common flags and concepts:

- `--deny-all`
- `--allow-net`
- `--deny-net`
- `--allow-funcs`
- `--deny-funcs`

Recommended stance:

- begin with `--deny-all`
- allow only the specific network targets and function families you need
- treat untrusted SurrealQL similarly to untrusted code execution

Example shape:

```bash
surreal start rocksdb://data/prod.db \
  --user "$SURREAL_USER" \
  --pass "$SURREAL_PASS" \
  --deny-all \
  --allow-net api.example.com \
  --allow-funcs http
```

## APIs, GraphQL, and SDKs

SurrealDB 3 can sit behind your application, but it can also expose useful database-native surfaces directly.

### `DEFINE API`

v3 stabilized `DEFINE API`, making it reasonable when:

- you want thin, data-native endpoints
- auth logic belongs close to the data model
- you want fewer repetitive CRUD wrappers in app code

Do not overuse it for business workflows that clearly belong in application orchestration.

### GraphQL

GraphQL in v3 is real enough to plan around.

Highlights:

- stable GraphQL support landed with v3
- permissions apply
- auth flows are supported
- depth and complexity controls matter
- subscriptions were added by v3.0.4

Use GraphQL when consumers already expect it. Do not force it when SurrealQL or SDK usage is simpler.

### SDK reality

SurrealDB has official SDK support across major ecosystems including:

- JavaScript / TypeScript
- Python
- Go
- Rust
- Java
- .NET

Also documented in the ecosystem and docs are additional bindings and integration surfaces.

Practical rule:

- validate SDK feature parity before assuming every v3 database feature is equally mature everywhere
- if you need the fastest-moving v3 feature coverage, check the current SDK release notes first

Notable v3-era SDK direction:

- JavaScript release notes describe full SurrealDB 3 support, multi-session support, automatic token refresh, client-side transactions, and a redesigned live-query API
- Go release notes mention structured error handling for SurrealDB 3 server errors

### Using SurrealDB optimally with the Rust SDK

If Rust is your main application language, prefer the Rust SDK as the primary integration layer instead of dropping to raw HTTP for normal app work.

Use these defaults:

- use the official Rust SDK for remote or embedded access
- prefer typed SDK methods for routine CRUD flows
- use `.query()` for complex SurrealQL, but bind values instead of interpolating strings
- model records with Rust structs that derive `SurrealValue` when possible
- keep record IDs explicit in your domain types
- use `FETCH` deliberately when linked records should deserialize into richer Rust shapes
- use live-query streams only where push semantics are actually needed

Rust SDK facts worth remembering:

- the docs show two common startup paths: remote connection over WebSocket and embedded use
- the docs describe `connect()` / `new()` for connection setup
- the docs recommend structs implementing `SurrealValue` as the ergonomic typed path
- the docs expose typed methods such as `select`, `create`, `update`, `delete`, `insert`, and `query`
- the docs call out that `.query()` is powerful but deserves extra security care because it can execute arbitrary SurrealQL

### Rust SDK usage pattern that scales well

1. keep one shared database handle per process or app context
2. centralize namespace/database selection and auth setup
3. separate **input DTOs**, **persisted record types**, and **API response types** when their shapes differ
4. use typed SDK methods for simple table/record operations
5. reserve raw SurrealQL for graph traversals, advanced filtering, search, analytics, and schema work
6. hide SurrealQL strings behind repository or query-layer functions instead of scattering them through handlers

### Rust SDK example shape

```rust
use surrealdb::Surreal;
use surrealdb::engine::remote::ws::Ws;
use surrealdb_types::SurrealValue;

#[derive(Debug, Clone, SurrealValue)]
struct UserRecord {
    id: surrealdb::RecordId,
    email: String,
    display_name: String,
}

#[derive(Debug, Clone, SurrealValue)]
struct NewUser {
    email: String,
    display_name: String,
}

async fn create_user(db: &Surreal<surrealdb::engine::remote::ws::Client>, input: NewUser) -> surrealdb::Result<Option<UserRecord>> {
    db.create("user").content(input).await
}
```

That shape is good because:

- create/update payloads are distinct from stored records
- the stored record includes the record ID explicitly
- the type used at the SDK boundary is stable and testable

### Rust SDK query guidance

Prefer this order of choice:

1. typed method like `select()` / `create()` / `update()` / `delete()`
2. typed method plus `fetch()` / live support where needed
3. `.query()` with bound parameters for advanced SurrealQL

Avoid this:

- assembling SurrealQL with user input via string concatenation
- returning raw untyped database values deep into application code
- letting handlers know SurrealQL details that belong in a data-access layer

## End-to-end type safety

SurrealDB can be used in a type-safe way, but you do not get true end-to-end safety by accident.

The best pattern is to make one contract flow through:

1. SurrealDB schema
2. Rust domain and persistence types
3. request / response DTOs
4. frontend types or external API schema

### What “good” E2E type safety looks like here

- schemafull tables for important data
- explicit field definitions for required fields and constrained types
- explicit relation shapes
- Rust structs for every persisted record shape you actually depend on
- separate input/output types where the wire shape differs from the stored shape
- typed query results at the repository boundary
- no ad-hoc `Value` parsing in handlers or UI glue code

### Best-practice pattern

Use three layers of types:

#### 1. Database record types

These match what is actually stored and returned by SurrealDB.

- include `id`
- include nullable/optional fields honestly
- reflect linked-record or fetched-record shape intentionally

#### 2. Command/input types

These model what your application accepts.

- omit generated fields
- keep validation-oriented shape
- use narrower enums/newtypes where possible

#### 3. API/view types

These model what leaves your backend.

- flatten or reshape database details as needed
- do not leak internal graph/storage structure unless the client truly needs it

### Practical rules for E2E safety

- prefer schemafull tables for core entities
- define field constraints in SurrealDB and mirror them in Rust types
- use enums/newtypes in Rust for closed sets instead of loose strings
- treat record IDs as first-class typed values, not plain strings everywhere
- keep one canonical module for persisted record definitions
- map database records to API DTOs explicitly when shapes differ
- keep raw `surrealdb::Value` at the edges, not across the app
- test deserialization of real query results, especially for traversals and `FETCH`

### How to avoid type drift

Type drift usually appears when one of these changes without the others:

- `DEFINE FIELD`
- query projection shape
- fetched relation shape
- Rust struct fields
- API response schema

To prevent that:

- keep schema files in the same repo as Rust types
- review SurrealQL projections whenever DTOs change
- prefer explicit projections over `SELECT *` for externally consumed query shapes
- write integration tests that deserialize actual query outputs into your Rust types

### Strong recommendation for Rust teams

For the best practical E2E type safety:

- define schema in versioned `.surql` files
- define one Rust type per stable persisted shape
- define separate DTOs for create/update/read flows
- use typed SDK methods where possible
- use `.query()` only behind typed repository functions that immediately deserialize into explicit structs
- expose frontend contracts from your backend schema or DTO layer, not from ad-hoc JSON blobs

If you do that, SurrealDB becomes type-safe in practice even when using advanced SurrealQL features.

### Optimal Rust project layout for E2E type safety

If you want the cleanest long-term setup, use a **Cargo workspace** with clear boundaries between:

- schema
- persistence/query code
- domain logic
- transport contracts
- application/server wiring

Recommended shape:

```text
myapp/
├── Cargo.toml                  # workspace root
├── db/
│   ├── migrations/
│   │   ├── 0001_init.surql
│   │   ├── 0002_indexes.surql
│   │   └── 0003_access.surql
│   ├── seeds/
│   └── queries/
│       ├── user/
│       │   ├── get_profile.surql
│       │   └── search.surql
│       └── org/
├── crates/
│   ├── app/                    # binary crate: axum/actix server, job runners, CLI
│   ├── db/                     # SurrealDB integration, repositories, query execution
│   ├── domain/                 # core business types and rules, DB-agnostic where possible
│   ├── contracts/              # API DTOs shared across backend/tests/optionally frontend generation
│   ├── auth/                   # auth/session/access helpers
│   └── testing/                # fixtures, test helpers, embedded/local test harness
├── web/                        # optional frontend app
│   ├── src/
│   └── generated/              # generated client/schema/types if applicable
└── docs/
    └── architecture.md
```

This is optimal because each layer owns exactly one kind of truth.

### What each crate should own

#### `crates/domain`

Put here:

- domain concepts
- invariants
- enums and newtypes
- pure business logic
- ID wrapper types if you use them above raw record IDs

Keep out:

- SurrealQL strings
- HTTP request/response structs
- framework types

#### `crates/contracts`

Put here:

- request DTOs
- response DTOs
- externally visible payload shapes
- serialization contracts you are willing to keep stable

This crate is the best source of truth for frontend-facing types.

Do **not** make persistence structs your public contract by default.

#### `crates/db`

Put here:

- the SurrealDB client wrapper
- repository implementations
- persisted record structs
- query result structs
- mapping from DB shapes into domain/contracts
- migration bootstrapping

This crate should be the only place that really knows SurrealDB details deeply.

That means:

- `RecordId`
- `FETCH`-specific shapes
- graph traversal query outputs
- index-aware query design
- raw `.query()` calls

#### `crates/app`

Put here:

- server startup
- routing
- dependency injection / state wiring
- background jobs
- request handling orchestration

Handlers should call services/repositories and return contracts.

Handlers should **not**:

- construct SurrealQL
- deserialize raw DB values
- know storage-specific graph shapes unless absolutely necessary

#### `crates/testing`

Put here:

- test fixtures
- seeded scenarios
- helpers that spin up local or embedded SurrealDB
- assertion helpers for typed query outputs

This keeps your integration tests from duplicating setup code badly.

### Optimal type flow inside that layout

Use this flow consistently:

```text
.surql schema
  -> persisted record structs in crates/db
  -> domain mapping in crates/domain
  -> API DTOs in crates/contracts
  -> generated or mirrored frontend types
```

That is better than these common bad layouts:

- one huge `models.rs` for everything
- handlers talking directly to `Surreal<Value>`
- sharing DB record structs directly with the frontend forever
- inline SurrealQL scattered across routes and services

### Recommended file-level structure inside `crates/db`

```text
crates/db/src/
├── client.rs
├── lib.rs
├── ids.rs
├── error.rs
├── migration.rs
├── repositories/
│   ├── mod.rs
│   ├── user_repo.rs
│   └── org_repo.rs
├── records/
│   ├── mod.rs
│   ├── user_record.rs
│   └── membership_record.rs
├── queries/
│   ├── mod.rs
│   ├── user_queries.rs
│   └── org_queries.rs
└── mapping/
    ├── mod.rs
    ├── user_mapping.rs
    └── org_mapping.rs
```

This is the clean cut because it separates:

- connection concerns
- persisted shapes
- query definitions
- repository orchestration
- mapping logic

### Best rule for query ownership

Every non-trivial query should have exactly one owner:

- either a repository method
- or a dedicated query module

Not both.

If a query feeds one API use case, keep the projection shape local to that use case.

If a query result is reused broadly, promote it into a named typed struct.

### Best rule for DTO ownership

Keep three distinct struct families when the shapes differ:

- `*Record` for database persistence
- `*Input` / `*Command` for writes
- `*Dto` / `*Response` for external reads

Example:

- `UserRecord`
- `CreateUserInput`
- `UserProfileDto`

That naming discipline prevents accidental leakage of storage concerns into your API.

### Best rule for schema ownership

Keep schema under `db/migrations/*.surql` and treat it like code:

- reviewed in PRs
- versioned
- applied in order
- referenced by integration tests

Do not hide important schema in one boot-time Rust string.

### Best frontend contract strategy

If the frontend is TypeScript, the optimal setup is usually:

- Rust backend owns `contracts`
- backend exposes OpenAPI/JSON Schema/typed endpoint contracts from those DTOs
- frontend consumes generated types from that contract layer

If the frontend is also Rust, share the `contracts` crate directly when practical.

Either way, the frontend should depend on the **API contract layer**, not on SurrealDB record structs.

### Best integration-test strategy

Have tests assert the full typed path:

1. apply `.surql` migrations
2. insert realistic fixture data
3. run repository/query function
4. deserialize into typed Rust struct
5. map into contract DTO
6. assert returned payload shape

That is the fastest way to catch:

- schema drift
- query projection drift
- record/DTO mismatch
- broken `FETCH` assumptions
- auth and permission surprises

### Anti-patterns to avoid

- `SELECT *` in externally consumed queries
- one struct reused as DB row, domain model, and API payload
- raw `Value` or untyped JSON escaping the repository layer
- SurrealQL embedded directly in handlers
- frontend types handwritten separately from backend DTOs
- migrations, Rust structs, and API schemas evolving independently

If you avoid those, your Rust + SurrealDB setup stays maintainable and genuinely type-safe as the schema grows.

## Deployment and Storage Choices

Choose storage based on operational requirements, not hype.

### Memory

Use for:

- tests
- throwaway development
- ephemeral workloads

Do not use it where persistence matters.

### RocksDB

Use for:

- persistent local or single-node deployments
- general-purpose server workloads
- mature operational expectations

### SurrealKV

Use when you want SurrealDB’s native storage path and features such as documented time-travel-oriented behavior.

### Distributed / larger deployments

Use documented distributed deployment guidance when:

- compute and storage separation matters
- clustering and larger-scale operations matter
- you need explicit platform-level scaling plans

## Operational Notes That Matter in v3

- `surreal upgrade` is the standard binary upgrade path.
- Read release notes for every minor and patch jump.
- Import/export behavior changed over time in 3.0.x.
- As of **v3.0.4**, imports through the `/import` endpoint require the `OPTION IMPORT` line present in exported `.surql` output.
- If you want import side effects to run, remove `OPTION IMPORT` and use `/sql` instead.
- v3 added better logging and observability features, including slow-query logging and improved log/file options.

## Migration Guidance: v2 to v3

Do not treat this as a casual patch upgrade.

Migration checklist:

1. read the current official 2.x → 3.x upgrade guide
2. read the v3 release notes, not just blog posts
3. inspect schema features that changed semantics
4. review indexes, computed fields, permissions, and any custom functions or APIs
5. test imports and exports on a disposable copy before production cutover

Migration-specific things to watch:

- old future-style field patterns need v3 computed-field thinking
- planner behavior is newer and often better, so old query workarounds may be obsolete
- MTree assumptions are obsolete for vector work
- export/import details changed during v2.6.x and 3.0.x, so use current tooling instead of stale shell history
- release notes explicitly call out migration diagnostics for schema-specific actions

## Good Default Recommendations

If you are starting fresh on v3:

- use schemafull tables where correctness matters
- use explicit relation tables for important graph edges
- keep computed fields derived and minimal
- use full-text search for keyword search, vector search for semantic retrieval, and combine them only when the use case justifies it
- start production servers from `--deny-all`
- validate every SDK behavior you depend on against the version you ship
- pin your operational playbook to the exact 3.0.x release, not “v3 generally”

## What Not To Assume

- do not assume old v2 blog posts are still accurate
- do not assume every SDK exposes every v3 feature equally
- do not assume vector search replaces full-text search
- do not assume record references and relation tables are interchangeable
- do not assume permissive startup defaults are safe for production
- do not assume import/export semantics stayed constant across early 3.0.x patches

## Verification Sources

Verified from official SurrealDB sources on 2026-04-07:

- FAQ: https://surrealdb.com/docs/surrealdb/faqs
- Releases: https://surrealdb.com/releases
- SurrealDB 3 launch blog: https://surrealdb.com/blog/introducing-surrealdb-3-0--the-future-of-ai-agent-memory
- Capabilities docs: https://surrealdb.com/docs/surrealdb/security/capabilities
- Start CLI docs: https://surrealdb.com/docs/surrealdb/cli/start
- Import CLI docs: https://surrealdb.com/docs/surrealdb/cli/import
- References docs: https://surrealdb.com/docs/surrealql/datamodel/references
- `DEFINE FIELD` docs: https://surrealdb.com/docs/surrealql/statements/define/field
- `DEFINE INDEX` docs: https://surrealdb.com/docs/surrealql/statements/define/indexes
- SurrealDB docs index / LLMs file: https://surrealdb.com/docs/llms.txt

If a claim in older examples conflicts with these sources, treat the official release notes and current docs as authoritative.
