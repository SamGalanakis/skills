---
name: testsmash
description: "Run an agent-orchestrated audit of a codebase's whole test and eval approach. Catalogs every test as delete (frivolous or tautological), unclear, or keep; reviews expect and snapshot, property, fuzz, simulation, chaos and soak, e2e, and eval harnesses as systems and proposes extensions where real gaps exist; and proposes new approaches (types, expect tests, property, model-based, differential, metamorphic, fuzz, deterministic simulation, chaos, soak and load, replay, mutation, contract, formal methods, evals) where they fit the code. The coordinator inventories every test as a coverage contract, fans out catalog, harness, gap and approach agents sized to the repo, independently verifies every deletion and every gap, then ranks. Use when the user wants a test-suite audit, says the tests are slop, bloated, or agent-written, wants to know whether a green suite means anything, or wants better eval infrastructure. Changes nothing in the repo: no edits, commits, or pushes; mutation probes run only in a throwaway copy."
---

# Testsmash

Audit what the suite can catch, not what it executes. A test is worth the plausible defects it fails on, minus what it costs to run, read, and keep green. Agents are rewarded for a green suite and a coverage number, so they write tests that mirror the implementation: they pass today, pass after the feature is deleted, and bury the few tests that matter. Coverage counts execution; only an independent oracle counts as checking.

Tests have a second job: showing behavior to the humans and agents who must understand a change. A well-chosen example, or a readable trace committed beside the code, turns a logic diff into a behavior diff a reviewer can read. Credit that, and scale scrutiny to what a defect in that code would cost.

Audit only. Do not edit, commit, or push. Running the suite and read-only commands is allowed. A mutation probe (break one line, run the tests that claim it) is allowed only in a throwaway worktree or copy, discarded afterwards.

You are the coordinator. Continue until every test has a verdict and the final audit is validated.

## The Three Questions

Ask them of every test, at every tier:

1. **Which plausible defect makes this fail?** Name the mutant. No answer means the test checks nothing.
2. **Where does the expected value come from?** A spec, a hand-derived value, a reference implementation, or an invariant is an oracle. The code under test, a helper it shares, a stub, or an unread snapshot is a mirror.
3. **What breaks it that is not a defect?** A test that fails on a behavior-preserving refactor taxes every change and trains people to re-bless.

## Verdicts

- **delete**: no plausible defect fails it, or its oracle is a mirror. Give a reason code and the surviving mutant.
- **unclear**: intent cannot be recovered from the test, its history, or the code, or its value depends on a fact you cannot establish. State the one question that would settle it.
- **keep**: name the behavior it protects and one mutant it kills. Optionally `strengthen` (what assertion is missing) or `merge` (into which test).

A bad test of important behavior is `delete` plus a gap entry, never `keep`. Unproven is `unclear`, never `delete`: a wrong deletion costs more than a wrong keep.

Reason codes for `delete`:

| Code | Shape |
|---|---|
| `mirror` | expected value computed by the code under test, a shared helper, or constants pasted from the implementation |
| `mock-echo` | asserts a stub returned what it was told to; the unit under test is itself mocked |
| `no-oracle` | no assertion, or only does-not-throw, non-null, truthy, type, or length |
| `cannot-fail` | assertion inside a branch, swallowed exception, uncalled callback, skip or xfail, always-true condition |
| `tests-the-platform` | getters, constructors, derives, enum variants exist, stdlib or framework behavior, facts the type system already guarantees |
| `impl-lock` | asserts call order, private state, or exact log text; fails on refactor, passes on bug |
| `blind-snapshot` | captured output nobody could review: huge, noisy, unformatted, or nondeterministic; re-blessed in bulk with the change that moved it |
| `duplicate` | same path and same oracle as another test; cases that add no new input partition |
| `dead` | exercises code unreachable from production |

Example tests are not the lesser tier. Software is brittle: wrong by a little is usually wrong by a lot, and types make it more rigid, so a few examples pressed in the right places catch a wide range of defects. Keep an example when someone chose it: it presses a boundary or a soft spot of the implementation, documents intended behavior, or pins a real past bug, however ugly. Choosing inputs from knowledge of the implementation is good; asserting on its internals is `impl-lock`. A one-line assertion against a hand-derived value for a pricing rule is a keeper. Delete examples nobody chose: the happy path restated, or cases that differ only in literals.

A captured-output (expect, snapshot, golden) test is an oracle exactly when a human could and did review the output. Small, deterministic, formatted to be read, and showing behavior unfold is `keep`, and often the best test in the file. The same mechanism dumping unread output is `blind-snapshot`.

If examples are instances of one law, propose one property and keep only the examples that name an edge case or a regression. If a type could make the tested state unrepresentable, say so instead of keeping the test.

## 1. Survey and coverage contract

Before spawning anything, read the repo yourself: languages and runners, tiers present (unit, integration, property, fuzz, simulation, e2e, snapshot, eval, bench), counts and wall time per tier, CI gates, skip and flake lists, existing harnesses and generators, coverage or mutation tooling, and where a defect would be most expensive in this domain.

Write one canonical scratchpad report holding: the test inventory (every test file with its test count, tier, subsystem, and assigned lane), the per-test catalog, harness reviews, the gap list, approach proposals, skips, and an audit log. The inventory is the coverage contract: every test belongs to exactly one lane, and no "misc" row proves coverage. Table-driven cases may share one row with a count.

## 2. Fan out, shaped to the repo

Use fresh agents, bounded to what you can coordinate, with non-overlapping ownership. Choose lanes from the survey, not from this list; drop roles the repo has no use for and split the ones it is heavy in.

- **Catalog workers**, one per lane of roughly 150 to 300 tests split along subsystem lines. Each returns one row per test: `file::name | tier | verdict | reason code | behavior protected | mutant survived or killed | action`. They may run tests and probe.
- **Harness reviewers**, one per expect or snapshot, property, fuzz, simulation, e2e, soak or chaos, or eval harness that exists. They give the same verdicts per test, then review the harness as a system through the lenses below and propose at most three extensions.
- **Gap scouts**, one per subsystem. They read the source first and the tests second, and never see catalog verdicts. They list the invariants, state machines, codecs, concurrency, persistence, and trust boundaries the subsystem has, then say which no surviving test would catch breaking.
- **Approach scout**, one for the whole repo: which techniques are absent and fit, with the ecosystem's library for each. The fit table is a floor; the scout also researches current practice for this stack and domain and what comparable projects run.
- **Infrastructure reviewer**, one: tier balance, what gates merges, inner-loop time (milliseconds, minutes, or hours to the first useful signal), flake and skip debt, determinism, how a failure is reproduced from CI output, fixture and re-bless workflow, and whether an agent working in the repo can close its own loop with these tests.

Harness lenses:

- **Examples and expect tests**: is the output curated for a reader (aligned, labelled, only the relevant state) or a raw dump; does a behavior change show up as a small legible diff in review; is output deterministic (no timestamps, addresses, map order); are accepts reviewed or bulk; do the committed examples tell a newcomer what the system is meant to do; could a trace through faked clock, network, and peers replace a pile of mock assertions.
- **Property**: does the generator reach the interesting space or discard most cases; is the property stronger than round-trip or does-not-crash; does it reimplement the function as its oracle; are failing seeds persisted as regressions; is a stateful or model-based test missing for a stateful API.
- **Simulation**: is it library-level (components wired in-process over shared fakes, fast enough for the inner loop) or only whole-system; are clock, randomness, IO, and scheduling all controlled; which faults are injected (crash, restart, partition, reorder, duplicate, delay, disk error) and which are not; are invariants checked throughout or only at the end; safety and liveness both; do runs prove they reached the rare states (sometimes-assertions); does a seed replay exactly.
- **Chaos, soak, load**: is there a stated steady-state hypothesis and a pass criterion, or just a run that did not crash; which faults and durations are covered; are memory, handles, queue depth, and latency tracked over time; does it run on a schedule with results anyone reads.
- **E2E**: does it drive the production entry point and assert observable side effects (stored data, network, files, a reload round trip) instead of "it opens"; which of success, cancel, error, empty, and persistence paths are exercised; fixed sleeps; boundaries stubbed until nothing real runs.
- **Evals** (LLM or agent behavior): were failure modes observed in traces or brainstormed; binary pass or fail per failure mode, not holistic scores; code checks used where the criterion is objective; judges validated against human labels with TPR and TNR on held-out data; similarity metrics as the main signal; enough labeled failures to trust a rate.

Fit table for proposals:

| The code has | Propose |
|---|---|
| codec, parser, serializer, migration | round-trip and invariant properties; coverage-guided fuzz on untrusted input |
| pure logic with algebraic laws | property tests |
| stateful API with a simple mental model | model-based (stateful property) test |
| two implementations, old vs new, fast vs naive | differential test |
| no usable oracle (search, ranking, numerics, model output) | metamorphic relations |
| an invariant a representation could enforce | types first: make the state unrepresentable and delete the tests |
| behavior easier to recognize than to specify (traces, protocols, rendered output, state over time) | expect tests: print a curated, readable trace, commit it, review the diff |
| components talking through clocks, networks, and other services | library-level deterministic simulation: shared fakes wired in-process, millisecond runs, traces captured as expect output |
| concurrency, retries, crash recovery, distribution | deterministic simulation with fault injection, whole-system where library-level cannot reach |
| unsafe, FFI, manual memory, or lock-level threading | sanitizers and interleaving checkers |
| resilience claims about a deployed system (failover, backpressure, degradation) | chaos experiments: injected faults in a real environment against a steady-state hypothesis |
| long-lived processes, caches, pools, queues | soak tests for leaks, drift, and exhaustion; load and stress tests for limits |
| a rewrite, migration, or risky change, with real inputs on record | replay of historical inputs; side-by-side run of old and new with diffing |
| performance as a requirement | benchmark regression gates |
| a critical module whose tests are unproven | mutation testing scoped to it, gated on the changed surface |
| service or plugin boundary | contract tests |
| a fixed bug with no test | regression test; replay past fixes reverted to see if the suite notices |
| invariants only tests know | runtime assertions in the code, checked by every tier |
| a protocol or state machine whose design is the risk | model checking the design; bounded model checking the code |
| a small kernel where a defect is catastrophic | refinement types or proof; a simple reference implementation proven or differentially tested equal to the fast one; proof that a diff preserves stated properties |
| LLM or agent behavior | trace error analysis, then code checks, then validated binary judges |
| UI flows | driven verification against a feature map |

A proposal must name its first concrete property, invariant, relation, or scenario, its oracle, the seam it needs (and whether that seam exists), and the defect class it catches that nothing does today. "Add property testing" is not a finding. Prefer the cheapest technique that catches the class, and the fastest tier it can run in: a type before a test, an example before a property, library-level simulation before whole-system. Propose simulation, chaos, or proof only where that is where the bugs or the cost are.

## 3. Verify, deduplicate, rank

Verify independently before accepting. Every `delete`: re-read the test and confirm the named mutant survives, by probe where cheap and by reasoning where not; downgrade to `unclear` on doubt. Every gap: search for a test that already covers it, at any tier. Every proposal: confirm the seam and the library exist. Reject proposals that restate coverage, add a tier with no named defect class, or exist for symmetry.

Promote a slop shape repeated across three or more lanes to a pattern with one rule that would stop it at authoring time. Then run one fresh coverage pass: which tests, harnesses, or subsystems does the inventory miss? Audit any real omission as its own row.

## Output

Lead with the numbers: tests per tier split into delete, unclear, keep, plus lines and CI time removable. Then, briefly:

1. Deletion clusters by reason code, largest first, each with one quoted example.
2. Unclear tests grouped by the question that settles them.
3. Extensions to existing harnesses.
4. New approaches, ranked by defect cost covered over effort, each with its first concrete test.
5. Authoring rules that would have prevented the top patterns.

The full per-test catalog lives in the report, referenced once. No code, no plan, no methodology recap. End with one line naming the first move, then stop.

Complete only when every test has a verdict, every deletion and gap was re-verified by you, and the repository is unchanged.
