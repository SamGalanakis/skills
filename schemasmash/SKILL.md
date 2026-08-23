---
name: schemasmash
description: "Run a read-only, agent-orchestrated audit of a codebase's data representations — in-memory types and data structures, database schema, and the serialized shapes between them — for states that are representable but invalid, multiple sources of truth for one fact, ordering or counts stored instead of derived, boolean-flag and nullable-field state machines, stringly-typed values, god objects and god tables, layer drift, and invariants the types or schema fail to enforce. The coordinator inventories every representation cluster as a coverage contract, fans out bounded read-only reviews, independently verifies every finding, and audits the audit before ranking. Use when the user wants a data-model or type-design review, says the domain model or schema has grown janky, is about to add a feature that touches core types or tables, or wants agent-written code checked before bad representations compound. Strictly read-only: no edits, migrations, tests, commits, or pushes."
---

# Schemasmash

Audit the representations, not the algorithms. Premise: representation shapes implementation. A type, table, or payload that can express an invalid state forces every reader and writer to handle it; one that cannot makes the downstream code self-evident. All slop starts as a bad data structure, and a ~12% per-feature rate of bad representation choices compounds into an unrecoverable codebase within a hundred features — so representations are the highest-leverage thing to review, especially when much of the code is agent-written and nobody reads the downstream code.

This is an audit-only exercise. Do not edit files, write migrations, run tests, implement recommendations, commit, or push. Read-only inspection commands are allowed.

You are the coordinator. Continue until every representation cluster has been reviewed and the final audit is validated.

## The Three Questions

Every finding reduces to one of three questions, asked of any representation regardless of where it lives:

1. **Can this represent a state that must never exist?** (invalid-but-representable)
2. **Can one real state be represented more than one way?** (duplicate truth)
3. **When the domain gains one more state or relationship, how many places change?** (amplification)

Apply them to every place a fact is shaped: in-memory structs, classes, enums/unions, collections, state objects, config, DTOs; tables, columns, constraints, indexes, documents, key-value shapes; JSON/protobuf/serialized forms, API payloads, save/restore formats, event schemas, cache entries, queue messages, in-flight request state, and CLI/env config. The lenses below are the recurring ways these questions get answered badly; the layer is incidental.

## Core Model

- Every struct, row, and payload is a value of a type. Ask whether every representable value is meaningful and whether every meaningful state has exactly one representation.
- Invalid-but-representable states are the root defect. Each one is a branch every consumer must write, and every branch is a place a future change (or a future agent) forgets.
- Redundant representations are the second defect. Two fields, columns, or collections that must agree will eventually disagree; the code keeping them in sync is pure liability.
- Fold requirements into structure: exclusivity into a tagged union or enum, ordering into an ordered collection or key that is the only source of order, cardinality into the container or a foreign key, per-state data into the variant that owns it, counts into a derived query.
- Change cost is the test. Simulate the next plausible feature and count touch points.
- Convenience is the enemy. Humans and models both reach for the representation that is easiest to write right now (add a bool, add a nullable, add a cache map). That is the compounding-slop signature.
- Gather broadly, report narrowly: cover every cluster, report the handful whose consumers branch the most.

## 1. Establish the coverage contract

Inspect the repository and inventory every representation cluster: a domain concept together with every shape it takes across layers (its in-memory type(s), its table(s)/documents, its wire/serialized form(s), its cache or queue form, and the conversions between them).

Give each cluster:

- a stable ID and descriptive name;
- an exact ownership boundary: the definitions it owns at each layer, by file and symbol;
- the conversion/serialization sites between its layers;
- its major consumers (the code that interprets its state) and tests;
- a status: queued, in review, recommend, or skip.

Include config/env shapes, event and message schemas, generated contracts, and cross-service payloads where materially relevant. A cluster that exists in only one layer is still a cluster.

Create one canonical scratchpad report containing:

- the cluster inventory;
- confirmed findings;
- explicit skip decisions;
- cross-cutting patterns (the same bad shape repeated across clusters);
- duplicates and superseded findings;
- final priorities and dependencies;
- an audit log.

Treat this inventory as the coverage contract. Do not assume broad catch-all rows ("misc models") prove coverage.

## 2. Run bounded cluster reviews

Use fresh, read-only agents where available. Give every worker one distinct cluster with an exact, non-overlapping ownership boundary. Keep concurrency bounded to the number of lanes you can actively coordinate. Use one consolidated wait mechanism, do not interrupt productive workers merely because they are slow, and close completed workers after harvesting their results.

Each worker receives this brief:

> Review the assigned representation cluster for at most two materially useful representation fixes. Stay inside the ownership boundary; you may name cross-cluster concerns but do not expand scope to solve them. Read-only.
>
> Ask the three questions of every shape in the cluster: can it represent a state that must never exist; can one real state be represented more than one way; how many places change when one more state or relationship is added.
>
> Look through these lenses at every layer (types, schema, wire):
>
> 1. **Flag-combination state machines** — several booleans or optionals (`held: bool, sold: bool`; `is_archived`, `deleted_at`, `sold_at`) jointly encoding a state that should be one enum/union with per-variant data. Count the meaningful subset of the 2^n combinations.
> 2. **Multiple sources of truth** — an ordering `Vec` beside a keyed map; a counter beside the things it counts; `status` plus the timestamps that imply status; a cache with no invalidation owner; the same entity redefined per layer with drift.
> 3. **Ordering stored instead of derived** — manual index maps, position integers, sibling pointers, or sort-on-every-read where an ordered collection, sortable key, or composite key would carry order implicitly and unforgettably.
> 4. **Stringly-typed values** — `kind: String`, free-text status columns, magic strings, IDs with implicit formats, enum-shaped values with no enum.
> 5. **Optional-field protocols** — fields whose meaning depends on other fields ("`refund_id` is set only when refunded") with nothing enforcing it: a tagged union flattened into a struct or row.
> 6. **God objects and god tables** — wide structs, context bags, or tables accumulating an optional field per feature where each use touches a small subset; usually several entities sharing one shape.
> 7. **Missing structural enforcement** — invariants held in comments, docstrings, or runtime asserts that a newtype, non-empty collection, NOT NULL, uniqueness, foreign key, check constraint, or exhaustive match could hold.
> 8. **Time and clock ambiguity** — wall vs monotonic vs deterministic time for the same event, timestamps without timezone, expiry stored as both duration and deadline.
> 9. **Serialization coupling** — save/restore, export, or API code bound to the exact in-memory layout so a representation change fans out everywhere, or a wire shape dictating a bad in-memory shape.
> 10. **Layer drift** — the type, the table, and the payload model the same concept with different state sets, nullability, or ordering guarantees, joined by lossy conversions.
> 11. **Convenience-shaped additions** — fields, maps, flags, and tables that mirror how the last feature was easiest to write rather than what the domain is; usually recent, check blame.
> 12. **Feature-add amplification** — simulate the next plausible feature and count the types, arms, columns, and code paths that must change.
>
> Decision rules: if a state reads as "X or Y or Z" in prose it is one enum/union, not flags; if a variant carries data, model the variant and its data together (payload variant in code; enum column plus constrained nullables or per-variant table in schema); if two things must agree, delete one or make the structure enforce agreement; if order matters exactly one thing carries it; a wildcard/default arm is suspect; a boolean being added is secretly a variant of some enum; if a concept is defined in more than one layer, name the owning layer and make the others tested conversions. Do not confuse normalization with correctness — denormalize deliberately, with a single owner. Do not trade an invalid-state problem for a performance problem without saying which the workload can afford.
>
> Do not force an abstraction. Prefer boring local code when it is already clear. Do not recommend changes solely for stylistic consistency, hypothetical extensibility, or moving existing branching behind a new type.
>
> Return at most two findings. If nothing clearly meets the threshold, return `skip`.
>
> For every finding provide:
>
> 1. Verdict: recommend or skip.
> 2. Evidence: the quoted type definition, DDL, or schema, with exact file and line references, at every layer it spans.
> 3. The concrete invalid combinations or duplicate truths, and whether any live values, fixtures, or rows are already in them (if data or tests are available).
> 4. For duplicate truths: at least one write path that updates one copy and not the other, or an explicit statement that none was found and the risk is latent.
> 5. Consumer blast radius: the grep and the count of sites that interpret this representation; for amplification claims, the simulated feature and its touch points.
> 6. Target representation at each affected layer, and how the layers map to each other. Give the type, not the diff.
> 7. Smallest credible implementation scope, regression risks, and migration/compatibility concerns.
> 8. Existing and additional validation required.
> 9. Confidence: high, medium, or low.

## 3. Validate and synthesize

Independently verify every finding against the current repository before accepting it: re-open the quoted definitions, re-run the consumer grep, and re-derive the invalid-combination count yourself.

Reject, narrow, or demote findings that are vague, duplicate another finding, misunderstand intentional semantics (a deliberate denormalization with an owner is not a duplicate truth), trade representation for an unstated performance cost, or merely relocate complexity behind a new type.

Record skips as completed coverage. Deduplicate overlapping findings and assign each accepted finding to one authoritative cluster. Promote a shape that recurs across three or more clusters to a cross-cutting pattern with one canonical fix.

Continue opening bounded review batches until every inventory row is complete.

## 4. Audit the audit

Before finishing, run fresh independent passes for:

- coverage: representation clusters and layers missing from the inventory (config, events, caches, generated contracts, cross-service payloads);
- duplication and ownership overlap between findings;
- materiality and over-abstraction: findings that add a type without removing an invalid state or a duplicate truth;
- evidence completeness: every finding has quoted definitions, concrete invalid states, consumer counts, and a target at each layer;
- dependency-aware priority ranking: which representation fixes unblock or subsume others.

If the coverage pass finds a real omission, add an explicit cluster row and audit it. Do not hide it by broadening a previously completed boundary.

## Output

Rank accepted findings by consumer blast radius, invalid-state count, likelihood of being touched by upcoming features, confidence, and implementation effort. Identify the best first fix.

Present findings first as a concise list ordered by severity.

- Prefer a short top-N list over exhaustive coverage; the full inventory and skip log live in the scratchpad report, referenced once.
- Each finding is 1-3 sentences: the cluster and fields, the representable-but-invalid states or duplicate truths, and the target representation across layers.
- Include the consumer blast radius inline and which layers are affected.
- Then a short cross-cutting patterns section if any were promoted.
- Do not write code or migrations, and do not turn the report into a plan or essay.
- Avoid preamble, methodology recap, and long summaries unless the user asks for them.

End with at most one line naming which finding to fix first and why, then stop.

The audit is complete only when every cluster has a finding or an explicit skip, every finding has full evidence and a target at each layer, duplicates and weak abstractions are removed, priorities are internally consistent, and the repository remains unchanged.

## Relationship To Other Skills

- `audit-your-codebase`: broader simplification audit (control flow, algorithms, ownership); this skill goes deeper on representations alone and applies the same orchestration.
- `complexitysmash`: use when the drag is in control flow, module boundaries, or abstraction layering rather than in the data model.
- `performancesmash`: use when the problem is query shape, access patterns, or hops, not representation.
- `wholehog`: use after this audit when the user wants the target representation implemented directly with a clean cutover.
