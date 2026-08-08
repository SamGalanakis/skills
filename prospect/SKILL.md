---
name: prospect
description: "Benchmark your project against reputable peer projects and mine them for concrete improvements: survey your repo, clone references locally, extract enforceable mechanisms, audit your own code through each reference's written doctrine, verify every finding independently, and output a verified improvement batch. Use when the user wants to benchmark against comparable projects, mine external repos for practices, or run an outward-looking quality round."
---

# Prospect

Grade your project against named, inspectable peer projects instead of
abstract best practice. Extract mechanisms, not impressions: the lint table,
the CI gate, the schema shape, the written policy. Verify every finding
before reporting it.

## The pipeline

### 1. Survey your repo

Frame the repo in one paragraph: what kind of artifact it is, its scale, and
the two or three concerns that must never break. These feed the aspect list
in the next step.

Then build the **exclusion map** — the ground no finding may duplicate:

- every open issue/ticket in the tracker (id + title),
- every settled ruling and documented non-goal (ADRs, project instructions,
  past reviews).

Write it to a file and inject it into every agent you spawn, with the
instruction: skip anything it covers; if a finding extends an open item, name
the item and state only the delta. This is what makes repeat runs surface new
findings instead of re-finding known ones.

### 2. Decompose into aspects, pick references per aspect

List the aspects along which your project can be compared. Typical aspects:

- the product category (what it is — e.g. agent SDK, CLI, database client);
- the language and toolchain (e.g. large Rust workspace);
- each load-bearing concern from the survey (e.g. durability, streaming,
  concurrency, security);
- disciplines you want to level up (e.g. testing, release engineering,
  observability, docs).

For each aspect, pick the most respected project *for that aspect*. A
reference earns its place by excellence at one aspect; it does not need to
resemble your project otherwise — a database with a famous safety culture is
a valid durability reference for a web framework. One reference can serve
several aspects, and an aspect can have several references.

Ask the user for references they want included; fill the remaining aspects
with reputable picks and say which aspect each reference covers. A weak
reference is still useful: "their CI never runs the test suite" is a negative
benchmark worth reporting.

### 3. Clone references locally — always

Work from local clones, never from memory, blog posts, or web summaries:

```bash
git clone --depth 1 https://github.com/owner/repo.git /tmp/ref-<name>
```

Reuse `/tmp/ref-<name>` if it already exists. Every claim about a reference
must be verifiable in its working tree: quote the actual lints table, count
the actual assertions, open the actual CI workflow. If a reference cannot be
cloned, drop it.

### 4. Extract mechanisms

One reader agent per reference, all launched in parallel in the background.
Each returns a practices brief scoped to the aspects that reference was
picked for — extract whatever is enforceable and transferable there, not a
fixed checklist. Good examples of the kind of thing worth extracting:

- how a boundary or invariant is actually enforced (a dependency graph shape,
  a lint config, a custom check in CI), quoted from the tree;
- a testing harness or fixture convention that explains why their suite is
  trusted;
- a written doctrine document (style guide, architecture invariants, release
  checklist) — summarize its actual rules;
- a data-model or storage decision that sidesteps a problem you have;
- a release/versioning/deprecation policy with teeth;
- weaknesses — what not to copy is also a finding.

Let the reference steer the brief: a release-craft reference deserves
different questions than a durability reference. Ask each reader to end with
a short ranked list of adoptable practices.

"They care about quality" is not a finding. "They run cargo-semver-checks as
a required PR check, decoupled from release tooling, per
.github/workflows/x.yml" is.

### 5. Audit your repo through their lenses

Do not only read references for ideas to import. Convert each reference's
written doctrine into a review of your own repo: a reviewer agent reads the
doctrine document first (style guide, safety manifesto, architecture
invariants), then audits your codebase against those rules, with the
exclusion map in hand.

This consistently finds more than a generic "review this repo" prompt,
because the reference has already decided what matters and written falsifiable
rules. Run at least one doctrine-lens review plus one review of whatever
ground previous rounds under-covered.

### 6. Verify every finding

No finding ships unverified. The failure mode is a plausible-looking finding
a model asserted without checking; one bad claim discredits the whole batch.

- A separate verification fan-out re-derives every count, line number, and
  characterization from the working tree: "byte-identical" gets diffed,
  "N sites" gets recounted, "never called" gets grepped.
- Subtle correctness findings get verified by the strongest available model,
  or by hand, reading the actual code paths.
- Corrections are applied before anything is reported. Expect verification to
  change results: some claims strengthen, some die.
- Verifiers only verify; finders never verify their own findings.

### 7. Output

- **Report**: composite verdict; consensus findings with attribution
  (independent convergence between reviewers is the confidence signal);
  reference-derived practices ranked by impact; and a "considered, not
  adopted" list so the next run knows what was already evaluated.
- **Tickets** (when the user wants them): one checkable outcome each,
  verified figures only, detailed evidence below the fold, explicit delta
  statements against adjacent open tickets, cross-links applied.
- **Decisions**: findings that carry real design choices go to the user with
  the mechanics explained and a recommendation, before anyone implements
  against them.

## Subagent use

Prospecting is a fan-out workload; run it as one.

- **Tier the models.** Extraction and counting are cheap-model work
  (reference readers, verification fan-outs). Doctrine-lens reviews and
  verification of subtle correctness findings get the strongest models.
  Never let a bulk fan-out inherit an expensive default model.
- **Parallel and background by default.** All readers launch together;
  reviewers together; verifiers together. Synthesis is the only serial step.
  Keep working while agents run; never poll.
- **One agent, one job.** One reader per reference; one reviewer per lens;
  verifiers grouped by finding cluster.
- **Self-contained prompts.** Every agent gets the repo framing, the
  exclusion map, its scope, and an explicit output contract ("your final
  message is raw data for synthesis — no preamble"). An agent should never
  need a follow-up question.
- **Right-size the fleet.** A round is roughly: N readers (one per
  reference) + 2-3 reviewers + 2-3 verifiers + the orchestrator's own
  hand-checks. Beyond ~15 agents, split into phases and synthesize between
  them.

## Repeat runs

Each round: refresh the exclusion map (it grew), rotate in new references and
new lenses, aim reviewers at ground the last round under-covered, and carry
forward the "considered, not adopted" list. A round that finds nothing new in
covered ground and something real in fresh ground is the process working.
