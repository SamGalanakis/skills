---
name: prospect
description: "Prospect rock-solid peer projects for improvements to your own: survey your repo and its already-worked ground, mine local clones of reputable references for enforceable mechanisms, convert their written doctrine into audit lenses on your own code, assay every finding twice, and stake claims as a verified improvement batch. Use when the user wants to benchmark their project against the best comparable projects, mine external repos for practices, or run an outward-looking quality round."
---

# Prospect

Grade your project against named, inspectable peers — not abstract best practice.
Bring back **mechanisms, not vibes**: the lint table, the CI gate, the schema
shape, the written policy. Every finding is assayed before it ships.

Prospect is the outward-looking sibling of the inward audits (complexitysmash,
performancesmash). It feeds them: mined end-states become implementation
targets, and disputed decisions go to the owner before anything is built.

## The pipeline

### 1. Survey the territory

Frame your repo in one paragraph: what kind of artifact it is, its scale, and
its load-bearing concerns (the two or three things that must never break).

Then draw the **exclusion map** — the already-worked ground no finding may
duplicate:

- every open issue/ticket in the tracker (id + title),
- every settled ruling and documented non-goal (ADRs, CLAUDE.md, past reviews).

Write it to a file and inject it into EVERY agent you spawn, with the
instruction: skip anything it covers; if a finding extends an open item, name
the item and state only the delta. This single artifact is what makes repeat
prospecting runs converge on new signal instead of re-finding the same twenty
things.

### 2. Identify the lodes

Pick references in three deliberate categories — each answers a different
question:

1. **Same-domain rivals** — what does the market consider table stakes?
2. **Same-substrate exemplars** — the most respected projects in your
   language/toolchain: what does excellence look like here?
3. **Discipline exemplars from other domains** — projects famous for one
   transferable rigor (safety culture, fuzzing, release engineering) even if
   their domain is unrelated.

Ask the user for named references they want included; fill the categories
yourself with reputable picks. A weak or sloppy reference is still a lode:
negative benchmarks ("their CI never runs the test suite") are data.

### 3. Take local copies — always

Follow the localref approach: work from **local clones, never from memory,
blog posts, or web summaries**.

```bash
git clone --depth 1 https://github.com/owner/repo.git /tmp/ref-<name>
```

Reuse `/tmp/ref-<name>` if it already exists. Every claim about a reference
must be greppable in its working tree: quote the actual `[workspace.lints]`
table, count the actual assertions, open the actual CI workflow. If a
reference cannot be cloned, drop it rather than reviewing it from recall.

### 4. Mine the mechanisms

One reader agent per reference, all launched **in parallel, in the
background**. Each returns a practices brief scoped to what is *enforceable*:

- repo/workspace structure and how boundaries are enforced (not described);
- hygiene tooling and CI gates, quoted from config;
- testing strategy: harness shapes, fixture conventions, snapshot policy;
- error-handling conventions; release/versioning/deprecation discipline;
- written doctrine documents (style guides, architecture invariants) —
  summarize their actual RULES;
- an honest weaknesses section — what NOT to copy;
- a ranked "top N stealable practices" list, one sentence each.

"They care about quality" is worthless. "They run cargo-semver-checks as a
required PR check, decoupled from release tooling, quoted from
.github/workflows/x.yml" is a claim you can stake.

### 5. Grind the lenses — the highest-yield move

Do not only read references for ideas to import. **Convert each reference's
written doctrine into an audit lens pointed at your own repo**: a reviewer
agent reads the doctrine document first (their style guide, their safety
manifesto, their architecture invariants), then hunts your codebase through
its eyes, with the exclusion map in hand.

A doctrine-lens review consistently out-finds generic "review this repo"
prompts, because the reference has already decided what matters and written
down falsifiable rules. Run at least one doctrine lens plus one fresh-eyes
review of whatever your previous rounds under-covered.

### 6. Assay every finding

No finding ships unassayed. The anti-pattern to fear is the **salted mine**:
plausible-looking findings a model planted without checking — impressive ore
that assays to nothing, and one bad claim poisons trust in the whole batch.

- A separate verification fan-out re-derives every count, line number, and
  characterization from the working tree ("byte-identical" gets diffed,
  "N sites" gets recounted, "never called" gets grepped).
- The subtle correctness findings get verified by the strongest available
  model — or by hand — reading the actual code paths.
- Corrections flow back into the findings before anyone sees them. Expect
  verification to change results: some claims strengthen, some die. Both
  outcomes are the assay working.
- Verifiers verify; they never also find. Keep the roles in separate agents.

### 7. Stake the claims

- **Report**: composite verdict, consensus findings (who found what
  independently — convergence is confidence), reference-derived practices
  ranked by impact, and a "deliberately not adopted" list so the next run
  knows what was already considered.
- **Tickets** (when the user wants them): one checkable outcome each, verified
  figures only, evidence below the fold, explicit delta statements against
  adjacent open tickets, cross-links applied.
- **Rulings**: findings that carry real design decisions go to the owner —
  one question at a time, mechanics explained in prose, with a
  recommendation — before anyone implements against them.

## Efficient subagent use

Prospecting is a fan-out workload; run it like one.

- **Tier the models.** Extraction and counting are cheap-model work (reference
  readers, verification fan-outs). Adversarial doctrine-lens reviews and the
  assay of subtle correctness findings get the strongest models available.
  Never let a bulk fan-out silently inherit an expensive default.
- **Parallel and background by default.** All reference readers launch
  together; reviewers launch together; verifiers launch together. Synthesis
  is the only serial step. Keep working while agents run — never poll.
- **One agent, one job.** One reader per reference; one reviewer per lens;
  verifiers grouped by finding cluster. Finders never verify their own
  findings.
- **Self-contained prompts.** Every agent gets the repo framing, the exclusion
  map, its scope, and an explicit output contract ("your final message is raw
  data for synthesis — no preamble"). Agents must not need follow-up
  questions.
- **Right-size the fleet.** A full round is roughly: N readers (one per
  reference) + 2-3 reviewers + 2-3 verifiers + the orchestrator's own
  hand-checks. If a round needs more than ~15 agents, split it into phases
  and synthesize between them.

## Cadence

Prospect is repeatable. Each round: refresh the exclusion map (it grew),
rotate in new references and new lenses, aim reviewers at ground the last
round under-covered, and carry forward the "deliberately not adopted" list.
A round that finds nothing new in worked ground and something real in fresh
ground is the process succeeding.
