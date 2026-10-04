---
name: firehose
description: "Run a single project at maximum wall-clock throughput with many parallel agents: frontier planner plus cheap workers, a durable ledger, merge on fast gates, fix forward on a slightly-red main, and quality enforced at milestone boundaries. Trades intermediate stability for speed while keeping final quality. Use when the user wants a lot of work done on one codebase fast, says 'go wide', 'max throughput', or 'firehose'."
---

# Firehose

Get the most finished work into one project per unit of wall-clock time. You
are the orchestrator. Many agents write code; you keep them fed, unblocked and
converging. **Intermediate states may be broken; the end state may not.**

## The stance

1. **Stable end state, not stable intermediates.** Main may run slightly red.
   Quality is enforced at milestone boundaries, not per commit. Known bugs in
   intermediate commits are fine if a ticket exists.
2. **Generation is not the bottleneck.** Coordination, verification, CI
   capacity and decisions are. Optimise those, not the number of agents.
3. **The mode has an off-switch.** Firehose is for pre-release or pre-stable
   phases. When there is real state to protect (a production release, user
   data, a stable API), durability gates turn back on. Write down where the
   switch is before you start. Until the switch, format-version bumps and
   durability gates are off: every stored format is reset once at the release.

## Before scaling up

Do not fan out until these exist. They make everything after them cheap.

- **The oracle.** A fast, near-perfect test suite whose failures print a short,
  readable summary, with a sampled or quick mode for agents. Agents converge on
  whatever the oracle rewards, so a weak oracle means fast convergence on wrong
  code.
- **A release gate.** The full suite plus the milestone checks (durability,
  conformance, E2E), run on main when the milestone's work is done. It need
  not be secret; it is simply never on the per-merge path.
- **The ledger.** All work state lives outside sessions: tickets (one checkable
  outcome each), a decision log, and a short "for the human" review file. Any
  session can die or be replaced and resume from the ledger.
- **The milestone.** One named milestone listing what "done" means. Everything
  in it blocks the release; everything else is post-milestone.

## Roles

- **Human:** sets direction and rules on genuine scope or taste questions,
  asynchronously and in batches, by reviewing the orchestrator's revisit
  list. Never a blocker: the orchestrator never waits on an answer.
- **Orchestrator (you):** runs rounds, routes work, makes design calls not
  reserved for the human, keeps the ledger honest. Reads summaries, not
  transcripts. Gets notified; does not poll in a loop.
- **Leads / planners (frontier model):** each owns an area or arc. They decompose
  it into tickets, make the design decisions and write them down, and review
  what the workers produce.
- **Workers (cheap model by default):** mechanical and well-specified tasks.
  Escalate to a frontier lane after two misses. Judge cost per finished run,
  not per token: a cheap worker that thrashes costs more.
- **Reviewers:** independent, fresh-context, correctness and spec only. Used
  sparingly (see Verification).

## Task decomposition

- Every task has a **machine-checkable "done when"**. If you cannot say how a
  test or command proves it, the task is not ready to dispatch.
- **Reuse warm sessions.** An idle session that just finished similar work is
  better than a cold one: route related tasks to it. Start a fresh session only
  when the instructions change substantially, because resumed sessions tend to
  follow their old plan.
- Worker specs are self-contained: context, exact files, steps, out of scope,
  verify commands, deliver steps. Include the repo's commit and PR rules.
- **Decompose along real dependencies**, not along headcount or file
  ownership (see *Parallelism*).
- Before dispatching, ask whether the task is already fixed, already moot
  (its code is being deleted), or folded into planned work. Stale-ticket
  sweeps are cheap worker tasks.

## Plan by dependencies, never by time

Agents have no calendar. A plan is a graph; a status report says what is
ready, in flight, or blocked, and on which edge. No dates, no ETAs.

- **Mark every edge HARD or SOFT.** HARD: the code cannot be written until X
  exists. SOFT: file overlap, "after it merges", "after review", habit. Most
  edges are soft. Break them.
- **Break soft edges three ways:** write the interface down and build against
  it; stack work on the unmerged branch; split along the seam.
- **Freeze interfaces first.** A short design doc per seam, written before the
  fan-out, unblocks every lane that builds against it.
- **Staff the critical path.** It is the longest chain of hard edges. Put your
  strongest lanes on its unsplittable nodes, more than one where you can;
  send everything off the path to cheap workers.
- **One question per node, every round:** is it unblocked? Then it has a lane
  now.
- **Measure progress in critical-path nodes cleared,** not merges or tickets.

## Parallelism

Parallelize like a good team: optimize for wall time.

1. **Always take the free parallelism.** Anything already independent runs
   at once, never queued behind something it does not need: separate crates,
   separate tickets, audits, tests, docs, the per-item pieces of a sweep.
2. **Buy parallelism where it is cheap.** When one piece needs what another
   produces and splitting clearly finishes sooner, pin the seam first
   (interface, types, behaviour, the check that proves it). Then both sides
   build at once against it, on a stub or stacked on the producer's unmerged
   branch.
3. **Do not split what does not split.** If carving a task up costs more
   coordination than it saves, one worker does it whole. Some tasks fall
   naturally into ten small ones; some are one tight piece of reasoning.
4. **Name the integrator.** Usually whoever lands second and rebases; for a
   wide change, one worker owns the final merge. A merge costs far less than
   waiting.

Sharing files or a subsystem is never by itself a reason to serialize.
Serialize only where the design cannot be pinned yet (decide it first) or
where two workers would rewrite the same logic.

Examples:
- Storage cutover: pin the new store trait and table shape; each store
  backend, the engine callers, the conformance laws and the differential then
  proceed in parallel, and one worker integrates.
- A consumer of new data: pin the method it reads; build it on a stub or on
  the producer's branch.
- API + UI: pin the request, response and error schema; endpoint and UI build
  in parallel against shared fixtures.
- Do not split: one subtle concurrency fix in one function. Two workers would
  only collide.

Also:

- **Launch everything unblocked now.** No slot quotas.
- **Remove hot files.** Files everyone edits (registries, generated
  inventories, shared expectation tables, changelogs) serialise the swarm.
  Shard them per change, derive them, or batch the conflicting work into one
  integration PR. **Resolve conflicts in generated files by regenerating them,
  never by hand-merging.**
- When several parallel PRs keep re-conflicting on the same files, stop
  rebasing them individually. Batch them into one PR, then fix the file layout.
- Stop adding agents to an area once coordination cost dominates. The signal
  is agents waiting on each other or undoing each other's work.
- Give each worker its own fork or worktree, and remove it once its PR merges.

## Merging

- **PR CI runs only fast gates plus the tests the change affects:** build,
  lint, formatting, the cheap policy checks. Full suites and E2E run on main on
  a schedule, never per PR, so they don't eat shared CI capacity. Long suites
  never block a merge. A PR with an already-FAILED check
  still waits.
- Run an **automatic merger** (see `scripts/fast-merger.sh`). It admin-merges
  any ready PR that passes the fast gates. Authors opt out with a draft or a
  `hold` label.
- **Drafts are for work that is not finished.** Once local verification is
  solid, mark the PR ready immediately. Never leave finished work parked
  waiting for a review round.
- **Never re-run gates just because main moved.** Once a branch's gates are
  green, a clean rebase or merge onto newer main needs only a build. Re-run
  tests only when the merge produced real changes: a conflict resolved in
  logic, not in generated files. Then re-run only the tests the resolved code
  affects. The scheduled full run on main catches the rest, and it gets fixed
  forward. A lane that keeps re-running its full suite to catch up with main is
  chasing, and chasing never lands.
- **The land step is the last line against a red main.** Before every push it
  runs the workspace-wide compile/lint aggregate (all crates, examples and test
  targets) on the rebased tree, and refuses a red push. A lane's own gate is not
  enough: workers scope checks, and two clean changes can combine into a red
  main. Pair it with a stall alarm: no new commit on main for ~40 min while
  lanes run wakes the orchestrator.
- **Gate once, on final code, through the project's build driver.** Workers
  run the workspace-wide lint or type check once, on the finished change,
  before the first landing attempt, and never again because main moved. The
  landing loop is rebase, build, push; a rejected push loops, and there is no
  hold or landing window to ask for. All builds and tests go through the
  project's shared driver and cache (for example its Bazel or remote-cache
  wrapper), never a raw local toolchain call that bypasses them and redoes
  work the pool already has. Scope test runs to the affected targets.
- **Put shared mechanics in the one place every worker reads** (the worker
  launcher's preamble or the repo's agent instructions), not in reminder
  messages to individual lanes. When a round finds a lane wasting gates,
  fix that shared text so the next lane never needs the note.
- Batch size is free. What matters is **attributability**: every failure must
  map back to a change and its author.
- **Don't let AI attribution trailers leak into commits or PR text** when the
  repo forbids them. The merger refuses such PRs.

## Keeping main usable

- Run the **full suite on main on a schedule** instead of per PR. Pick the
  interval so a run is still current when it finishes: when main moves fast
  (dozens of commits per hour), every few hours, not hourly.
- **Don't overchase red main.** Two classes:
  - *Breaks everyone* (compile, lint, schema, policy gates): fix now with one
    small cheap lane. The per-push compile and the land checks surface these
    within minutes, well before the full run.
  - *Test reds*: a **culprit-finder agent** (a cheap worker, never a frontier
    model) maps each to the change that caused it and routes it to **the
    author to fix forward**, on that change's ticket. No dedicated lane unless
    it is on the critical path or a durability bug. Revert only when the fix
    is slower to verify than the revert, or main is unusable for everyone.
- Skip triage of a run whose head is already superseded by known fixes;
  triaging every other run is plenty.
- If main has been red for more than one full-run cycle on the same failure,
  escalate: revert, or put a frontier lane on it.
- **Cutting the milestone:** when its work is done, stop feature merges, fix
  the remaining reds, run the release gate, and cut from main.

## Verification

- **Tests are the oracle.** Don't make a failing test pass by weakening it: no
  longer timeouts as a "fix", no blind retries. A flake gets fixed deterministically
  (wait on events or state, not wall-clock time) or quarantined with a ticket
  to its owner.
- **Run new and changed tests once, and confirm they actually executed.** No
  repeat runs for confidence or flake-hunting: main's scheduled full run is the
  oracle, and flakes it surfaces get fixed forward. A name filter that matches
  nothing reports N/N green, and a sharded test binary reports a pass from
  every shard that ran zero tests. Use full test paths and check that the log
  says a test actually passed.
- **Review sparingly.** One independent review only for hard,
  durability-critical or first-of-kind changes. Findings get fixed forward
  after merge; never do a second review round.
- **The release gate is where quality is enforced:** the full suite and the
  durability checks all green on main at the cut.
- **Test compute is a shared, budgeted resource.** Size CI reservations from
  measurements, keep expensive suites off the merge path, and track the
  known-expensive tests explicitly.

## Decisions

- **Never block on the human.** Small calls: the lead decides and notes it on
  the ticket. Big design calls: the orchestrator decides (optionally after a
  second-model critique), logs the call with its rationale and how reversible
  it is, and adds it to the human's review file.
- **Never use a blocking question tool during a firehose run** (one that
  stops the session until the human answers). A pending answer can stall
  every lane for hours. Decide, act on the decision immediately, and append
  it to a "for the human to revisit" list in the review file: the call, the
  recommended alternative, the evidence, how reversible it is, and what
  revisiting would cost. The human reviews that list asynchronously and
  overrides when they want.
- Ask only when the action is irreversible or outward-facing and has no
  standing grant (publishing, pushing to someone else's repo, deleting
  shared state). Even then, park just that one action and keep every other
  lane moving.
- Record standing human rulings where every future session will read them
  (project memory or instructions), so they are never re-litigated.

## The orchestrator's round

Run it on a timer, e.g. every 30 min:

1. The merger and the scheduled full run are alive, restarted if not.
2. Every open ready PR: a failed check → re-run a known flake, else route it
   to its author. Conflicting for too long → a worker rebase.
3. Main's latest full run: route every red to its culprit's author.
4. Answer lead and lane questions; decide or escalate.
5. Unowned or stale tickets: staff them, fold them, or close them with
   evidence.
6. Audit running workers for waste: raw toolchain calls that bypass the
   shared driver, gates re-run after a clean rebase, suites broader than the
   change. Fix the shared worker text, then nudge the offenders.
7. Clean up forks and worktrees of merged work. Log anything noteworthy to the
   run notes.

## Resilience

- Assume sessions die: rate limits, capacity outages, restarts. Because state
  lives in the ledger and forks, recovery means re-attaching or relaunching
  from the ledger, never reconstructing from memory.
- Wrap cheap-worker runs in a retry loop for transient capacity errors, and
  resume the same session after an interruption.
- After a restart, check every background loop (merger, scheduled runs, timed
  rounds) and every lane. Background jobs usually die with the session that
  started them.

## Failure modes to watch

- Agents implementing the same design differently. Fix: the planner writes the
  design down first.
- Two workers rewriting the same logic. Fix: pin the seam first, or give it
  to one worker.
- Independent work queued behind one big unit. Fix: pin its seams, fan out,
  and stack dependents on its unmerged branch.
- A swarm avoiding the hard core code. Fix: assign the core explicitly to a
  frontier lane.
- Main drifting red for long stretches, or regression cascades. Fix: the
  culprit-finder routing above.
- Green results that executed no tests.
- Cost blow-ups from auto-merging with no cost cap.
- Human burnout. Keep the human's queue short and asynchronous.
- The whole run idling behind one unanswered question. Fix: decide, log it
  for revisit, move on.

## Don't

- Run flat peer swarms that coordinate through locks.
- Use a cheap model as the orchestrator or planner.
- Write huge or auto-generated instruction files.
- Keep firehose on after the off-switch condition is met.

## Sources

Cursor, "agent swarm model economics" and "self-driving codebases";
Steve Yegge on Gas Town, Beads and the Land Rush; Geoffrey Huntley's "ralph"
loops; Cognition on multi-agent systems and Devin Fusion; Anthropic's
multi-agent research system and C-compiler write-up; SpecBench; Google's
presubmit/postsubmit testing; Julien Danjou on batching and attribution.
