---
name: spring-cleaning
description: Full codebase health pass in two phases — first delete dead things (unused code, deps, shims), then restructure what remains (dedup, abstractions, pattern normalization, efficiency).
---

# Spring Cleaning

Full codebase health pass. Two phases, in order.

## Phase 1: Subtract

**"Should this still exist?"**

Delete things. The codebase gets smaller.

1. **Dead code** — Unused functions, types, modules, imports, variables, and constants. If nothing calls it, remove it.
2. **Unused dependencies** — Dependencies in the manifest that aren't imported anywhere. Remove them.
3. **Backwards compatibility shims** — Deprecated APIs, migration helpers, legacy type aliases, re-exports kept only for old consumers. If the migration window has passed, remove them.
4. **Abandoned experiments** — Half-finished features behind dead flags, commented-out code blocks, modules that were started but never wired in.
5. **Stale config** — Environment variables, feature flags, or config keys that nothing reads anymore.
6. **Orphaned files** — Files that aren't imported, included, referenced, or served anywhere. Stale test fixtures, unused assets, leftover scripts, generated files that aren't regenerated.
7. **Gitignore hygiene** — Check `.gitignore` for patterns that no longer apply (removed tooling, old build dirs). Add missing patterns for things that shouldn't be tracked (build artifacts, editor files, OS files, secrets, `.env`).

Catalog (don't delete) **TODOs and placeholders** — search for `TODO`, `FIXME`, `HACK`, `XXX`, placeholder implementations. Present a list with location (file:line), brief description, and suggested priority.

## Phase 2: Restructure

**"Should this be structured differently?"**

Reshape what survived Phase 1. The codebase gets better organized.

1. **Deduplication** — Duplicated logic, copy-pasted code, or near-identical implementations that could be unified into a shared function, trait, or module.
2. **Missing abstractions** — Places where a shared trait, interface, type, or helper would reduce repetition and make the code more expressive.
3. **Module splits** — Large modules doing too many things that should be broken into focused pieces.
4. **Pattern normalization** — Inconsistent approaches to the same problem (e.g., error handling done three different ways). Pick the best pattern and normalize.
5. **Coupling** — Tightly coupled code that should be disentangled so pieces can change independently.
6. **Efficiency** — Unnecessary allocations, redundant operations, or suboptimal algorithms where a simpler or faster approach exists.
7. **Dependency leverage** — Vendored or hand-rolled code that an existing dependency already handles, or dependencies that could replace verbose manual implementations.

## Why This Order Matters

Delete first, restructure second. No point deduplicating code that should be deleted. No point extracting abstractions from dead modules.
