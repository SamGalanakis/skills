---
name: spacetimedb
description: Build, model, secure, test, and deploy current SpacetimeDB systems with Rust server modules and Rust clients. Covers tables, reducers, subscriptions, auth, scheduling, codegen, publishing, schema/index guidance, Rust/WASM concerns, and current SDK gotchas. Target release: v2.1.0.
---

# SpacetimeDB v2.1.0

Use this skill for SpacetimeDB architecture, module design, Rust server modules, Rust client SDK work, real-time subscriptions, auth, scheduling, schema evolution, and deployment.

Assume:

- **Rust server modules** running as **WASM** in SpacetimeDB
- **Rust clients** using the official **`spacetimedb-sdk`**
- current upstream release behavior unless the local project pins something older

## Version Notes

- **Target release: SpacetimeDB `v2.1.0`**.
- **Exact upstream repo tag verified: `v2.1.0`**.
- **Workspace package version in upstream repo: `2.1.0`**.
- **Docs snapshot present in the upstream docs tree: `1.12.0`**.
- **Verified on 2026-04-15** against the official `clockworklabs/SpacetimeDB` repo, its docs tree, Rust templates, and Rust SDK sources.

Important nuance:

- The upstream repo currently exposes **release/tag version `v2.1.0`** while the docs site content in-repo is versioned as **`1.12.0`**.
- When examples or phrasing differ, prefer this order:
  1. **latest tagged upstream release and workspace version**
  2. **current templates and SDK source in the same repo**
  3. **current docs pages in the repo**

## What SpacetimeDB Is Good At

SpacetimeDB is best treated as a **database that is also your application server**.

It is especially strong when you want:

- real-time state sync without manually building websocket replication
- a single authoritative backend for multiplayer, collaboration, or shared state apps
- application logic close to the data, not split across API server + cache + database
- direct client subscriptions to selected state
- strongly typed client/server contracts generated from module definitions
- Rust backend logic compiled to WASM, deployed as a database module

Typical good fits:

- multiplayer and social games
- collaborative apps
- live dashboards and presence systems
- chat, lobbies, rooms, turn systems
- simulation/stateful backends with many connected clients

## Core Mental Model

Design around these ideas first:

1. **A database is an application** in SpacetimeDB, not just storage.
2. **Tables hold authoritative state**.
3. **Reducers are the write API** and run atomically.
4. **Subscriptions replicate selected rows** into a client-side cache.
5. **Clients should read mostly from subscribed local state**, not constantly issue ad hoc fetches.
6. **Schema design is also network design** because table layout affects replication size and frequency.
7. **Rust modules compile to WASM**, so keep module logic deterministic, lean, and data-oriented.

If you reach for “build a normal REST server in front of the DB,” pause. In SpacetimeDB, reducers and subscriptions usually replace that layer.

## Current Rust Project Shape

The current Rust template shape is:

```text
my-project/
├── spacetimedb/            # Rust server module
│   ├── Cargo.toml
│   └── src/lib.rs
├── src/                    # Rust client app
│   └── module_bindings/    # generated Rust bindings
├── Cargo.toml
├── spacetime.json
└── README.md
```

Core workflow:

```bash
# create project
spacetime dev --template basic-rs

# or manual creation
spacetime init --lang rust --project-path ./my-project my-project
cd my-project

# auth for cloud publishing
spacetime login

# from the module directory or project root workflow
spacetime publish <DATABASE_NAME>
```

Notes:

- `spacetime dev` is the fastest loop, but the docs explicitly mark it **unstable**.
- `spacetime publish` builds if needed, uploads the module, runs `init` if present, and updates an existing database atomically when possible.
- Rust and C# modules compile to **WASM**.

## Rust Module Basics

The canonical Rust server patterns are:

```rust
use spacetimedb::{ReducerContext, Table};

#[spacetimedb::table(accessor = person, public)]
pub struct Person {
    #[primary_key]
    #[auto_inc]
    id: u64,
    name: String,
}

#[spacetimedb::reducer]
pub fn add(ctx: &ReducerContext, name: String) {
    ctx.db.person().insert(Person { id: 0, name });
}
```

Keep these rules in working memory:

- Import **`Table`** whenever you use table operations like `insert`, `iter`, `find`, `update`, or `delete`.
- Rust table accessors are **snake_case methods** like `ctx.db.player()`.
- `public` on the table macro controls client visibility.
- Rust `pub` visibility on the struct is just Rust visibility; it does **not** make the table public to clients.

## Tables and Schema Design

### Prefer data-oriented decomposition

The docs strongly recommend splitting tables by **access pattern and update frequency**, not by “one big entity struct.”

Good:

- `Player`
- `PlayerState`
- `PlayerStats`
- `PlayerSettings`

Avoid one giant `Player` row containing:

- 60Hz position updates
- occasional health changes
- rare profile changes
- very rare settings changes

Why:

- reduces subscription bandwidth
- improves cache locality
- keeps responsibilities clearer
- allows safer schema changes

Rule of thumb:

- if data changes together and is read together, keep it together
- if data is read on different screens or at different frequencies, split it

### Public vs private tables

- Use **public tables** only for state clients truly need to replicate.
- Keep internal/admin/sensitive state in **private tables**.
- Reducers can read both.
- Clients can only subscribe to public tables and other exposed query surfaces.

### Table naming

For Rust modules:

```rust
#[spacetimedb::table(accessor = player_state, public)]
pub struct PlayerState { /* ... */ }

// accessed as:
ctx.db.player_state()
```

Choose stable snake_case accessor names early. Renaming them is effectively an API/schema change.

## Indexing Guidance

Use indexes for **actual query patterns**, not “maybe someday.”

SpacetimeDB supports:

- **B-tree indexes**: general-purpose default
- **Direct indexes**: dense unsigned integer sequences only

Rust examples:

```rust
#[spacetimedb::table(accessor = user, public)]
pub struct User {
    #[primary_key]
    id: u32,
    #[index(btree)]
    name: String,
    #[unique]
    email: String,
}

#[spacetimedb::table(
    accessor = score,
    index(accessor = by_player_and_level, btree(columns = [player_id, level]))
)]
pub struct Score {
    player_id: u64,
    level: u32,
    points: i64,
}
```

Use **direct indexes** only when all of this is true:

- key type is `u8/u16/u32/u64`
- values are dense
- values start near zero
- inserts are roughly sequential
- you genuinely need max lookup speed

Do **not** use indexes casually:

- they consume memory
- they slow inserts and updates
- primary keys and unique constraints already create indexes

Index-key gotchas:

- no `f32` / `f64`
- no `ScheduleAt`, `Timestamp`, or `TimeDuration`
- no `Vec<T>` or arrays
- no enums with payloads
- no nested structs

If you need indexed floats, store scaled integers instead.

## Reducers: Your Write API

Reducers are the default place for business logic.

Properties that matter:

- invoked by connected clients
- run in **atomic transactions**
- commit all changes on success
- roll back all changes on error

Example:

```rust
#[spacetimedb::reducer]
pub fn update_score(ctx: &ReducerContext, id: u64, points: i32) -> Result<(), String> {
    let mut player = ctx.db.player().id().find(id)
        .ok_or("Player not found")?;
    player.score += points;
    ctx.db.player().id().update(player);
    Ok(())
}
```

Design guidance:

- put authorization checks at reducer boundaries
- validate inputs before doing expensive work
- prefer explicit result errors over panics
- keep reducers small and purpose-specific
- do not model everything as a giant “update_state” reducer

Important transaction nuance:

- external reducer calls create transactions
- reducer-to-reducer direct calls do **not** create nested transactions
- there is no child transaction rollback boundary in those direct calls

So avoid assuming nested reducer calls behave like nested DB transactions.

## Lifecycle Reducers

Common Rust lifecycle hooks in current templates:

```rust
#[spacetimedb::reducer(init)]
pub fn init(ctx: &ReducerContext) { /* called on initial publish */ }

#[spacetimedb::reducer(client_connected)]
pub fn identity_connected(ctx: &ReducerContext) { /* per client connect */ }

#[spacetimedb::reducer(client_disconnected)]
pub fn identity_disconnected(ctx: &ReducerContext) { /* per disconnect */ }
```

Use them for:

- seeding initial rows in `init`
- presence tracking on connect/disconnect
- creating a user row on first connect
- validating auth provider and audience on connect

Avoid using them for:

- heavy one-time migrations better handled explicitly
- expensive fan-out work that blocks connection flow

## Identity and Authentication

SpacetimeDB uses **OIDC JWTs** for auth.

Key facts:

- the server validates the token
- claims are exposed to reducers and other contexts
- `sub` and `iss` determine user identity
- you should usually validate **issuer** and **audience** yourself in-module

Rust pattern:

```rust
const OIDC_CLIENT_ID: &str = "client_XXXXXXXXXXXXXXXXXXXXXX";

#[spacetimedb::reducer(client_connected)]
pub fn connect(ctx: &ReducerContext) -> Result<(), String> {
    let jwt = ctx.sender_auth().jwt().ok_or("Authentication required".to_string())?;
    if jwt.issuer() != "https://auth.spacetimedb.com/oidc" {
        return Err("Invalid issuer".to_string());
    }
    if !jwt.audience().iter().any(|a| a == OIDC_CLIENT_ID) {
        return Err("Invalid audience".to_string());
    }
    Ok(())
}
```

Security guidance:

- check at least **issuer** and **audience**
- do not trust “has JWT” as sufficient authorization
- centralize claim parsing helpers for role-based checks
- allow `is_internal()` paths when handling scheduled/internal execution where appropriate

## Subscriptions and the Client Cache

Subscriptions are a core feature, not an add-on.

How they work:

1. client subscribes to queries
2. initial matching rows are replicated to local cache
3. later matching inserts/updates/deletes stream automatically
4. client reads from the cache and reacts via callbacks

Rust subscription pattern:

```rust
let conn = DbConnection::builder()
    .with_uri("wss://maincloud.spacetimedb.com")
    .with_database_name("my_module")
    .on_connect(|ctx| {
        ctx.subscription_builder()
            .on_applied(|ctx| {
                for user in ctx.db.user().iter() {
                    println!("User: {}", user.name);
                }
            })
            .add_query(|q| q.from.user())
            .add_query(|q| q.from.message())
            .subscribe();
    })
    .build()?;
```

Prefer:

- **typed query builders** over raw query strings
- narrow subscriptions over “subscribe to everything”
- grouping subscriptions by lifetime
- local cache reads for UI and event handling

Callback patterns:

```rust
conn.db().user().on_insert(|ctx, row| { /* ... */ });
conn.db().user().on_update(|ctx, old, new| { /* ... */ });
conn.db().user().on_delete(|ctx, row| { /* ... */ });
```

Design guidance:

- subscribe only to data actually needed by the current screen/system
- separate always-on subscriptions from temporary ones
- treat table layout as part of replication performance design

## Rust Client SDK Guidance

Base dependency:

```bash
cargo add spacetimedb_sdk
```

Generate bindings:

```bash
mkdir -p src/module_bindings
spacetime generate --lang rust \
  --out-dir src/module_bindings \
  --module-path PATH-TO-MODULE-DIRECTORY
```

Then in the client:

```rust
mod module_bindings;
use module_bindings::*;
```

Core connection builder methods to know:

- `with_uri(...)`
- `with_database_name(...)`
- `with_confirmed_reads(...)`
- `with_token(...)`
- `on_connect(...)`
- `on_connect_error(...)`
- `on_disconnect(...)`
- `build()`

### Minimal Rust connection recipe

Use this as the default native-client shape:

```rust
mod module_bindings;
use module_bindings::*;

use spacetimedb_sdk::{DbContext, Table};

fn connect(host: String, db_name: String, token: Option<String>) -> DbConnection {
    let conn = DbConnection::builder()
        .with_uri(host)
        .with_database_name(db_name)
        .with_token(token)
        .on_connect(|ctx, _identity, _token| {
            ctx.subscription_builder()
                .on_applied(|ctx| {
                    for row in ctx.db.message().iter() {
                        println!("{}", row.text);
                    }
                })
                .add_query(|q| q.from.message())
                .subscribe();
        })
        .on_disconnect(|_ctx, err| {
            if let Some(err) = err {
                eprintln!("Disconnected: {err}");
            }
        })
        .build()
        .expect("Failed to connect");

    conn.db().message().on_insert(|_ctx, row| {
        println!("new message: {}", row.text);
    });

    conn.run_threaded();
    conn
}
```

Best-practice flow for Rust clients:

- connect with generated `DbConnection`
- subscribe in `on_connect`
- treat `on_applied` as the point where initial cache state is ready
- register row callbacks for live updates
- explicitly run the connection loop
- persist and reuse the token only if stable identity across sessions matters

### Critical runtime gotcha

If you do not advance the connection, **nothing happens**.

You must call one of:

- `run_threaded()`
- `run_async().await`
- `frame_tick()`

Otherwise:

- no messages are processed
- no subscriptions apply
- no callbacks fire

### Current Rust SDK gotcha

The docs call out a known bug where **`on_connect_error` may never fire** and `on_disconnect` is invoked instead.

So for production-quality error handling:

- wire both callbacks
- do not rely on `on_connect_error` alone

### Tokens and identity reuse

Rust clients can persist the private token returned on connect and pass it back with `with_token(...)` on later sessions to reconnect as the same identity.

This is the current template/chat example pattern.

## Rust Clients Targeting `wasm32`

The Rust SDK has a **`browser`** feature and `wasm32`-specific dependencies in the upstream SDK.

Treat Rust-in-the-browser as a separate runtime shape from native Rust:

- native clients use standard tokio/threaded patterns
- browser clients must respect wasm/browser async execution constraints
- SDK/browser support exists, but many real projects will still prefer TS for browser UIs unless Rust-on-web is a firm requirement

Guidance:

- if the client is browser-based and the team is already web-native, TypeScript is usually the lower-friction choice
- if you do use Rust `wasm32` clients, validate the exact SDK feature flags and runtime assumptions in the project’s `Cargo.toml`
- do not confuse **server module WASM** with **client browser WASM**; they are distinct targets and constraints

## Confirmed Reads

The Rust client builder exposes `with_confirmed_reads(bool)`.

Use it when you need reads only after durability confirmation, not just in-memory commit visibility.

Use cases:

- stronger durability semantics
- workflows sensitive to replica/disk confirmation timing

Tradeoff:

- potentially higher latency

If unspecified, the server chooses the default behavior.

## Scheduling and Periodic Work

SpacetimeDB supports schedule tables that trigger reducers or procedures at specific times or intervals.

Rust pattern:

```rust
use spacetimedb::{ReducerContext, ScheduleAt, Table};
use std::time::Duration;

#[spacetimedb::table(accessor = reminder_schedule, scheduled(send_reminder))]
pub struct Reminder {
    #[primary_key]
    #[auto_inc]
    id: u64,
    message: String,
    scheduled_at: ScheduleAt,
}

#[spacetimedb::reducer]
fn send_reminder(_ctx: &ReducerContext, reminder: Reminder) -> Result<(), String> {
    Ok(())
}

#[spacetimedb::reducer]
fn schedule_periodic_tasks(ctx: &ReducerContext) {
    ctx.db.reminder_schedule().insert(Reminder {
        id: 0,
        message: "tick".to_string(),
        scheduled_at: ScheduleAt::Interval(Duration::from_millis(50).into()),
    });
}
```

Use scheduling for:

- ticks and heartbeats
- expirations and TTL-like behavior
- reminders and delayed actions
- periodic maintenance

Remember:

- scheduled work should still be idempotent where practical
- scheduled reducers are trusted/internal paths, so auth logic may differ
- `ScheduleAt` itself is **not indexable**

## Procedures: Powerful but Beta

Procedures are for work reducers cannot do cleanly, especially side effects like HTTP requests.

But they are **not** the default abstraction.

Current guidance:

- procedures are **beta / unstable**
- prefer reducers unless you need procedure-specific capabilities
- in Rust, using procedures requires opting into unstable support in the module crate

Important difference from reducers:

- procedures do **not** automatically run in a DB transaction
- you must use `ProcedureContext::with_tx` / `try_with_tx` for DB access

Rust sketch:

```rust
#[spacetimedb::procedure]
fn insert_a_value(ctx: &mut ProcedureContext, a: u32, b: String) {
    ctx.with_tx(|ctx| {
        ctx.my_table().insert(MyTable { a, b });
    });
}
```

Important gotcha:

- the closure passed to `with_tx` may be invoked multiple times
- avoid capturing mutable external state that changes behavior across retries

## Good Rust Module Patterns

### Presence table keyed by `Identity`

This is a strong default for multiplayer/collaboration systems:

- `User` or `Session` table keyed by `Identity`
- `client_connected` creates or reactivates row
- `client_disconnected` marks offline

### Reducers own validation

- validate names/messages/IDs at reducer boundaries
- return `Result<(), String>` for user-facing failures
- avoid hidden mutation paths

### Use primary-key and unique accessors directly

Examples:

```rust
ctx.db.user().identity().find(ctx.sender());
ctx.db.player().id().find(id);
ctx.db.user().username().find("alice");
```

### Keep hot tables narrow

For fast-changing state:

- positions
- velocity
- health deltas
- room membership
- presence bits

keep rows tight and focused.

## Deployment and Publishing

Key commands:

```bash
spacetime build
spacetime publish <DATABASE_NAME>
spacetime publish --break-clients <DATABASE_NAME>
spacetime publish --delete-data <DATABASE_NAME>
```

Behavior that matters:

- publish builds automatically if needed
- new publish runs `init` if defined
- updates attempt automatic schema migration
- swap-in is atomic when possible
- active client connections are maintained across compatible updates

Use `--break-clients` only when you intentionally accept a client-breaking schema/API change.

Use `--delete-data` only when a full reset is truly intended.

## Schema Evolution Guidance

When changing a live database:

- prefer additive changes first
- keep accessor names stable
- stage client updates before breaking schema changes
- think about subscription compatibility, not only storage compatibility
- treat generated bindings as part of the public contract

Practical rule:

- if existing generated Rust client code would stop compiling or stop interpreting rows correctly, you are making a real contract change

## Testing and Dev Workflow

Recommended workflow:

1. start from `spacetime dev --template basic-rs` or `chat-console-rs`
2. edit `spacetimedb/src/lib.rs`
3. regenerate bindings when schema changes
4. exercise reducers with `spacetime call`
5. inspect state with `spacetime sql`
6. inspect logs with `spacetime logs`
7. validate subscriptions from a real client

Useful commands:

```bash
spacetime call add Alice
spacetime sql "SELECT * FROM person"
spacetime logs
```

Validation checklist when debugging:

- did the module publish successfully?
- did bindings regenerate after schema change?
- is the client connecting to the correct host/database name?
- is the connection being advanced?
- did subscriptions actually apply?
- is the table public if the client expects to read it?
- are issuer/audience checks rejecting the client?

## Good Default Recommendations

For most Rust-first projects:

- use **reducers**, not procedures, by default
- use **typed subscriptions** and generated bindings everywhere
- model data by **access/update pattern**
- keep public tables intentionally small
- use `Identity`-keyed user/session tables for presence
- validate auth issuer and audience on connect
- persist reconnect token if identity continuity matters
- start with B-tree indexes, use direct indexes only when clearly justified
- keep module logic simple, deterministic, and close to the state transitions

## What Not To Assume

- SpacetimeDB is **not** “just Postgres with websockets.”
- Reducers are **not** generic nested transaction boundaries.
- Public tables are **not** harmless; they define replicated client-visible data.
- The Rust client does **not** run itself; you must drive the connection.
- `on_connect_error` is **not** currently reliable enough to be your only failure path.
- Procedures are **not** the default server abstraction.
- One giant entity table is **not** the best default for replicated state.
- Server-module WASM and browser-client WASM are **not** the same problem.

## Verification Sources

Verified against the upstream `clockworklabs/SpacetimeDB` repository cloned locally with `localref`, especially:

- `Cargo.toml` — workspace version `2.1.0`
- `docs/versions.json` — docs snapshot `1.12.0`
- `README.md` — architecture and install/quickstart overview
- `templates/basic-rs/README.md`
- `templates/basic-rs/spacetimedb/src/lib.rs`
- `templates/basic-rs/src/main.rs`
- `templates/chat-console-rs/spacetimedb/src/lib.rs`
- `templates/chat-console-rs/src/main.rs`
- `sdks/rust/Cargo.toml`
- `sdks/rust/src/lib.rs`
- `docs/docs/00100-intro/00100-getting-started/00400-key-architecture.md`
- `docs/docs/00200-core-concepts/00100-databases/00200-spacetime-dev.md`
- `docs/docs/00200-core-concepts/00100-databases/00300-spacetime-publish.md`
- `docs/docs/00200-core-concepts/00100-databases/00500-cheat-sheet.md`
- `docs/docs/00200-core-concepts/00300-tables.md`
- `docs/docs/00200-core-concepts/00300-tables/00300-indexes.md`
- `docs/docs/00200-core-concepts/00300-tables/00500-schedule-tables.md`
- `docs/docs/00200-core-concepts/00400-subscriptions.md`
- `docs/docs/00200-core-concepts/00500-authentication.md`
- `docs/docs/00200-core-concepts/00500-authentication/00500-usage.md`
- `docs/docs/00200-core-concepts/00600-clients/00200-codegen.md`
- `docs/docs/00200-core-concepts/00600-clients/00500-rust-reference.md`
- `docs/docs/00200-core-concepts/00200-functions/00400-procedures.md`
