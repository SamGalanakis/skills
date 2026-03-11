---
name: datastar
description: Build HTML-first reactive web apps with Datastar on the frontend and a Rust backend. Use this skill for Datastar with Axum, Rocket, HTML/JSON/SSE responses, and the official datastar-rust SDK, including current release-vs-main caveats.
---

# Datastar (Rust Backend)

Build HTML-first, reactive web apps with Datastar on the frontend and Rust on the backend.

Datastar is a hypermedia framework. The backend remains the source of truth, the browser gets a small reactive layer through `data-*` attributes, and the server drives UI updates by patching HTML and signals over normal HTTP responses, especially SSE.

This document focuses on:

- how Datastar wants you to structure apps
- what the frontend actually sends and expects
- what the Rust SDK supports today
- where the docs and Rust repo are currently out of sync

## Version Notes

As of 2026-03-08:

- The official Getting Started guide loads the Datastar client bundle from `starfederation/datastar@1.0.0-RC.8`.
- The `datastar-rust` example HTML on GitHub `main` still loads `1.0.0-RC.7`.
- The published crate on crates.io is `datastar = 0.3.1`.
- The `starfederation/datastar-rust` `main` branch is ahead of crates.io at `0.3.2`.
- The published `0.3.1` crate exposes `axum`, `rocket`, `tracing`, and `http2` features.
- Warp support exists on GitHub `main`, but it is not in the published `0.3.1` crates.io release yet.
- The Datastar docs site has a Rust SDK entry, but some guide code switchers still say `No example found for Rust`.

Practical rule:

- Pin the frontend bundle intentionally.
- Prefer the crates.io release unless you explicitly need unreleased features.
- Treat older tutorials and examples as potentially version-skewed.

## What Datastar Is Optimizing For

The official Datastar philosophy matters because the framework is opinionated:

- Most state should live in the backend.
- The backend should drive the frontend by patching elements and signals.
- Signals should be used sparingly.
- Morphing is the default and is trusted heavily, including "fat morph" updates.
- SSE is the preferred response model.
- Navigation should stay normal web navigation with `<a>` tags and redirects.
- Browser history should stay browser-managed.
- CQRS maps naturally onto Datastar: long-lived read streams plus short-lived write requests.
- Loading indicators are preferred over optimistic UI.
- Accessibility remains your job: semantic HTML, ARIA where needed, keyboard support, screen reader support.

Datastar is not trying to turn your app into a client-state-heavy SPA with a custom router. If you find yourself inventing a lot of frontend orchestration, you are usually moving away from Datastar’s intended model.

## Core Mental Model

- The backend is the source of truth.
- Signals are client-visible and client-mutable state.
- HTML patches change structure.
- Signal patches change lightweight frontend state.
- SSE is the best fit when one interaction has multiple steps.
- Stable IDs are important because morphing matches top-level elements by ID.

For Rust apps this usually means:

1. Render the page on the server.
2. Add Datastar only where interactivity is needed.
3. Use small signals for UI-local concerns and request payloads.
4. Keep business rules and validation on the backend.
5. Stream patches over SSE when work is incremental or long-lived.

## Frontend Syntax You Should Write Today

Use the current suffixed attribute style.

Common attributes:

- `data-signals:name="expr"`: define or patch a signal
- `data-bind:name`: two-way bind an input-like element
- `data-computed:name="expr"`: derived signal
- `data-text="$name"`: set text content reactively
- `data-show="$open"`: conditional display
- `data-class:open="$open"`: toggle a class
- `data-attr:disabled="$busy"`: toggle or set an attribute
- `data-on:click="..."`: handle an event
- `data-effect="..."`: run an effect on load and when dependencies change
- `data-indicator:loading`: create a request-in-flight signal
- `data-init="..."`: run setup logic once Datastar initializes
- `data-json-signals`: debug current signals by rendering them as JSON
- `data-ignore`: ignore a subtree entirely
- `data-ignore-morph`: ignore a subtree during morphing only

High-value event modifiers:

- `__prevent`
- `__debounce.300ms`
- `__throttle.300ms`
- `__window`
- `__once`
- `__outside`

Important casing rules:

- Signal-defining suffixes are converted from hyphenated names to camelCase.
- Example: `data-signals:user-name="'Sam'"` becomes `$userName`.
- Non-signal suffixes usually normalize to kebab-case unless you use `__case`.

Important ordering rule:

- Attributes are evaluated in DOM order.
- This matters for combinations like `data-indicator:*` with `data-init`, where the indicator signal must exist before the request starts.

## What Datastar Sends To The Backend

Backend actions like `@get('/path')`, `@post('/path')`, `@put('/path')`, `@patch('/path')`, and `@delete('/path')` use the Fetch API.

Default request behavior:

- Datastar sends a `Datastar-Request: true` header.
- By default it sends all signals except underscore-prefixed ones.
- For `GET`, signals are sent as a `datastar` query parameter.
- For non-`GET`, signals are sent as a JSON request body.

Important consequence:

- Underscore-prefixed signals are excluded from the default request payload.
- They are a good fit for UI-local state that should not be sent automatically.

Useful action options:

- `filterSignals`: include or exclude signal paths with regexes
- `contentType: 'json' | 'form'`
- `selector`: choose which form to serialize when using `contentType: 'form'`
- `headers`: add custom request headers
- `openWhenHidden`: keep a hidden-tab stream open
- `payload`: override the fetch payload
- retry controls: `retry`, `retryInterval`, `retryScaler`, `retryMaxWaitMs`, `retryMaxCount`
- `requestCancellation`: control how overlapping requests cancel

Important form rule:

- `contentType: 'form'` submits form data instead of signals.
- In that mode Datastar validates the form and does not send signals.

## What The Backend Can Return

Datastar backend actions automatically handle four response content types:

- `text/event-stream`: standard Datastar SSE events
- `text/html`: HTML to patch into the DOM
- `application/json`: signal patch payload
- `text/javascript`: JavaScript to execute

The official Datastar philosophy strongly prefers `text/event-stream`, because it can already express element patches, signal patches, and script execution in one response stream.

### `text/event-stream`

Use SSE when you need:

- incremental updates
- progress reporting
- long-running tasks
- multiple patches in one response
- long-lived read streams
- coordinated element and signal updates

### `text/html`

Return plain HTML when the next UI shape is already known on the server.

Optional Datastar response headers:

- `datastar-selector`
- `datastar-mode`
- `datastar-use-view-transition`

Patch modes:

- `outer`
- `inner`
- `remove`
- `replace`
- `prepend`
- `append`
- `before`
- `after`

### `application/json`

Return JSON when only signals need to change.

Optional response header:

- `datastar-only-if-missing`

### `text/javascript`

Return JavaScript only as an escape hatch.

Optional response header:

- `datastar-script-attributes`

## Datastar SSE Events That Matter In Practice

The two core SSE event types are:

- `datastar-patch-elements`
- `datastar-patch-signals`

What they do:

- `datastar-patch-elements` morphs or patches HTML into the DOM
- `datastar-patch-signals` patches signal values into the current signal store

Important details:

- Top-level elements should have stable IDs.
- Child IDs inside morphed subtrees help preserve state such as focus, listeners, and transitions.
- Setting a signal to `null` removes it.
- `onlyIfMissing` prevents existing signals from being overwritten.
- SSE events must be separated by blank lines.

Example wire format:

```text
event: datastar-patch-elements
data: selector #results
data: mode inner
data: elements <div id="results"><p>Updated</p></div>
```

```text
event: datastar-patch-signals
data: onlyIfMissing true
data: signals {loading: false, resultsCount: 42}
```

## Rust SDK Status

The Rust SDK is useful when you want correctly formatted Datastar SSE events and framework-specific SSE event conversion.

### What The Published Crate Supports

Published on crates.io today:

- Axum support: yes
- Rocket support: yes
- Warp support: no, not in `0.3.1`

### What GitHub `main` Supports

On `starfederation/datastar-rust` `main`:

- Axum support: yes
- Rocket support: yes
- Warp support: yes, but unreleased

### What The Crate Exports

The prelude exposes:

- `DatastarEvent`
- `PatchElements`
- `PatchSignals`
- `ExecuteScript`
- `ElementPatchMode`

Framework-specific helpers:

- Axum: `write_as_axum_sse_event()`, `axum::ReadSignals<T>`
- Rocket: `write_as_rocket_sse_event()`
- Warp on `main`: `write_as_warp_sse_event()`, `warp::read_signals::<T>()`, `warp::ReadSignals<T>`

## Recommended Dependency Setup

### Axum On Crates.io

```toml
[dependencies]
axum = "0.8"
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
asynk-strim = "0.1"
datastar = { version = "0.3.1", features = ["axum", "tracing"] }
```

### Rocket On Crates.io

```toml
[dependencies]
rocket = { version = "0.5", features = ["json"] }
serde = { version = "1", features = ["derive"] }
datastar = { version = "0.3.1", features = ["rocket"] }
```

### Warp If You Intentionally Track GitHub `main`

Warp support is not part of the published `0.3.1` crate. If you need it, use the GitHub repo intentionally and accept the risk of unreleased API drift.

## Minimal Frontend Example

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Datastar + Rust</title>
    <script
      type="module"
      src="https://cdn.jsdelivr.net/gh/starfederation/datastar@1.0.0-RC.8/bundles/datastar.js"
    ></script>
  </head>
  <body>
    <main
      data-signals:query="''"
      data-signals:loading="false"
      data-signals:results-count="0"
    >
      <input
        type="search"
        placeholder="Search"
        data-bind:query
        data-indicator:loading
        data-on:input__debounce.300ms="@get('/search')"
      >

      <p>Results: <span data-text="$resultsCount">0</span></p>
      <div id="results"></div>
    </main>
  </body>
</html>
```

What this means:

- `query` is editable client state
- `loading` is toggled by `data-indicator`
- typing triggers a debounced backend request
- the backend can answer with SSE, HTML, JSON, or JavaScript

## Axum Pattern: Read Signals And Stream SSE

The Axum integration is the cleanest published Rust integration today.

- `ReadSignals<T>` extracts Datastar signals
- for `GET`, it reads the `datastar` query parameter
- for non-`GET`, it reads JSON from the request body
- the optional extractor variant returns `None` when `Datastar-Request` is absent

```rust
use {
    asynk_strim::{stream_fn, Yielder},
    axum::{
        response::{Html, IntoResponse, Sse, sse::Event},
        routing::get,
        Router,
    },
    core::{convert::Infallible, error::Error, time::Duration},
    datastar::{
        axum::ReadSignals,
        prelude::{PatchElements, PatchSignals},
    },
    serde::Deserialize,
};

const INDEX: &str = r#"<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Datastar + Axum</title>
    <script
      type="module"
      src="https://cdn.jsdelivr.net/gh/starfederation/datastar@1.0.0-RC.8/bundles/datastar.js"
    ></script>
  </head>
  <body>
    <main data-signals:delay="75" data-signals:loading="false">
      <input type="number" min="0" step="25" data-bind:delay>
      <button data-attr:disabled="$loading" data-on:click="@get('/hello')">
        Stream
      </button>
      <div id="message"></div>
    </main>
  </body>
</html>
"#;

const MESSAGE: &str = "Hello from Rust";

#[derive(Deserialize)]
struct HelloSignals {
    delay: u64,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let app = Router::new()
        .route("/", get(index))
        .route("/hello", get(hello));

    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000").await?;
    axum::serve(listener, app).await?;
    Ok(())
}

async fn index() -> Html<&'static str> {
    Html(INDEX)
}

async fn hello(ReadSignals(signals): ReadSignals<HelloSignals>) -> impl IntoResponse {
    Sse::new(stream_fn(
        move |mut yielder: Yielder<Result<Event, Infallible>>| async move {
            yielder
                .yield_item(Ok(
                    PatchSignals::new("{loading: true}").write_as_axum_sse_event()
                ))
                .await;

            for i in 0..MESSAGE.len() {
                let html = format!(r#"<div id="message">{}</div>"#, &MESSAGE[..i + 1]);
                yielder
                    .yield_item(Ok(
                        PatchElements::new(html).write_as_axum_sse_event()
                    ))
                    .await;

                tokio::time::sleep(Duration::from_millis(signals.delay)).await;
            }

            yielder
                .yield_item(Ok(
                    PatchSignals::new("{loading: false}").write_as_axum_sse_event()
                ))
                .await;
        },
    ))
}
```

## Rocket Pattern: Stream SSE, Parse GET Signals Manually

The published Rocket integration gives you SSE event writers, but not the same signal-extractor ergonomics as Axum.

The official example pattern is:

- route `GET /hello-world?<datastar>`
- parse query payload into `Json<T>`
- emit `EventStream![]`

```rust
use {
    core::time::Duration,
    datastar::prelude::PatchElements,
    rocket::{
        get, launch,
        response::{content::RawHtml, stream::EventStream},
        routes,
        serde::{Deserialize, json::Json},
    },
};

#[derive(Deserialize)]
#[serde(crate = "rocket::serde")]
struct Signals {
    delay: u64,
}

#[get("/")]
fn index() -> RawHtml<&'static str> {
    RawHtml(include_str!("index.html"))
}

#[get("/hello-world?<datastar>")]
fn hello_world(datastar: Json<Signals>) -> EventStream![] {
    EventStream! {
        let message = "Hello from Rocket";
        for i in 0..message.len() {
            let html = format!(r#"<div id="message">{}</div>"#, &message[..i + 1]);
            yield PatchElements::new(html).write_as_rocket_sse_event();
            rocket::tokio::time::sleep(Duration::from_millis(datastar.delay)).await;
        }
    }
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index, hello_world])
}
```

## Warp Status

Warp support is real on GitHub `main`, including:

- `datastar::warp::ReadSignals<T>`
- `datastar::warp::read_signals::<T>()`
- `write_as_warp_sse_event()`

But it is not shipped in crates.io `0.3.1`, so do not document or depend on it as if it were part of the released crate.

## When You Do Not Need The Rust SDK

You do not need the `datastar` crate for every endpoint.

Skip the SDK when:

- you only return plain `text/html`
- you only return plain `application/json`
- you do not need SSE event builders

In those cases, ordinary framework responses are fine as long as you set the correct content type and, when needed, the Datastar response headers.

Example HTML response in Axum:

```rust
use axum::{
    http::{HeaderMap, HeaderValue},
    response::Html,
};

async fn search_results() -> (HeaderMap, Html<&'static str>) {
    let mut headers = HeaderMap::new();
    headers.insert("datastar-selector", HeaderValue::from_static("#results"));
    headers.insert("datastar-mode", HeaderValue::from_static("inner"));

    (headers, Html("<div><p>Updated results</p></div>"))
}
```

Example JSON response in Axum:

```rust
use axum::{http::{HeaderMap, HeaderValue}, Json};
use serde_json::json;

async fn search_meta() -> (HeaderMap, Json<serde_json::Value>) {
    let mut headers = HeaderMap::new();
    headers.insert("datastar-only-if-missing", HeaderValue::from_static("false"));

    (headers, Json(json!({
        "resultsCount": 42,
        "loading": false
    })))
}
```

## Rust Event Builders You Actually Need

### `PatchElements`

Use for DOM updates.

```rust
use datastar::prelude::{ElementPatchMode, PatchElements};

let patch = PatchElements::new(r#"<div id="results">Updated</div>"#)
    .selector("#results")
    .mode(ElementPatchMode::Inner)
    .use_view_transition(true);
```

Useful facts:

- default mode is `outer`
- if no selector is provided, Datastar uses element IDs
- `PatchElements::new_remove(selector)` removes matching elements

### `PatchSignals`

Use for lightweight signal updates.

```rust
use datastar::prelude::PatchSignals;

let patch = PatchSignals::new("{loading: false, resultsCount: 42}")
    .only_if_missing(false);
```

Useful facts:

- the payload must evaluate as valid JavaScript object syntax
- later values overwrite existing values unless `only_if_missing(true)` is used
- setting a signal to `null` removes it

### `ExecuteScript`

Use only as an escape hatch.

```rust
use datastar::prelude::ExecuteScript;

let patch = ExecuteScript::new("console.log('hello from server')")
    .attributes(["type=\"module\""]);
```

## Recommended Backend Strategy

For most Rust apps:

1. Render the initial page on the server.
2. Add Datastar attributes to the smallest useful surface area.
3. Keep underscore-prefixed signals for UI-local state.
4. Return HTML or SSE first.
5. Use JSON for tiny state-only updates.
6. Use long-lived SSE `GET` streams for read-side updates when CQRS fits.
7. Keep writes as short-lived `POST`/`PUT`/`PATCH`/`DELETE` requests.
8. Validate everything on the backend.

This follows the official Datastar philosophy more closely than building a complex client-state layer.

## Security Rules

- Escape user input before it appears in HTML or Datastar expressions.
- Signals are visible to the client and can be modified before submission.
- Never trust signals for authorization, pricing, permissions, or other business invariants.
- Keep secrets and sensitive data out of signals.
- If you cannot safely escape some markup, isolate it with `data-ignore`.
- If you use CSP, you must allow `unsafe-eval`, because Datastar evaluates expressions with `Function()`.

Example CSP:

```html
<meta
  http-equiv="Content-Security-Policy"
  content="script-src 'self' 'unsafe-eval';"
>
```

## Sharp Edges

- Docs, repo examples, and crate releases are currently not perfectly aligned.
- The official docs philosophy is SSE-first, even though HTML and JSON responses are fully supported.
- The Datastar docs still have some missing Rust examples in guide switchers.
- The `datastar-rust` repo examples still reference frontend `RC.7` while the guide uses `RC.8`.
- Warp support exists on GitHub `main` but not in crates.io `0.3.1`.
- Attribute order matters.
- Morphing depends heavily on stable IDs.
- `data-ignore-morph` is important for third-party DOM and other non-Datastar-managed subtrees.
- `text/javascript` works, but using it too often is usually a sign that the app shape is drifting away from Datastar’s strengths.
- Optimistic UI is explicitly discouraged by the core team.

## Fast Workflow

1. Server-render the page.
2. Add a few signals only where user interaction needs them.
3. Use `data-bind`, `data-on:*`, and `data-indicator:*`.
4. Start with a simple backend endpoint.
5. Return HTML or SSE patches.
6. Add signal patches only for small client-visible state.
7. Use anchors and redirects for navigation.
8. Keep business logic and validation on the backend.

## Sources

- https://data-star.dev/guide/getting_started
- https://data-star.dev/guide/reactive_signals
- https://data-star.dev/guide/backend_requests
- https://data-star.dev/guide/the_tao_of_datastar
- https://data-star.dev/reference/attributes
- https://data-star.dev/reference/actions
- https://data-star.dev/reference/sse_events
- https://data-star.dev/reference/sdks
- https://data-star.dev/reference/security
- https://github.com/starfederation/datastar-rust
- https://crates.io/crates/datastar
