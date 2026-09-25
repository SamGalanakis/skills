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
   switch is before you start.

## Before scaling up

Do not fan out until these exist. They make everything after them cheap.

- **The oracle.** A fast, near-perfect test suite whose failures print a short,
  readable summary, with a sampled or quick mode for agents. Agents converge on
  whatever the oracle rewards, so a weak oracle means fast convergence on wrong
  code.
- **A held-out suite.** Tests or fixtures that workers never see or edit, run only
  at milestone gates. Agents pass visible tests near-universally; the hidden
  gap is where the real bugs are.
- **The ledger.** All work state lives outside sessions: tickets (one checkable
  outcome each), a decision log, and a short "for the human" review file. Any
  session can die or be replaced and resume from the ledger.
- **The milestone.** One named milestone listing what "done" means. Everything
  in it blocks the release; everything else is post-milestone.

## Roles

- **Human:** sets direction and rules on genuine scope or taste questions,
  asynchronously and in batches. Never a blocker.
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
- **One task per session.** Kill the session when the task is done and start a
  fresh one for the next. A resumed session is only for "continue the same
  task". When the instructions change, start a fresh session with a
  self-contained spec, because resumed sessions tend to follow their old plan.
- Worker specs are self-contained: context, exact files, steps, out of scope,
  verify commands, deliver steps. Include the repo's commit and PR rules.
- **Decompose along blockers and file ownership**, not along headcount.
- Before dispatching, ask whether the task is already fixed, already moot
  (its code is being deleted), or folded into planned work. Stale-ticket
  sweeps are cheap worker tasks.

## Parallelism

- **Launch everything unblocked now.** No slot quotas; parallelism is limited
  only by blockers and file overlap.
- **One writer per area at a time; reads fan out freely.** Separate worktrees
  stop file collisions but not design collisions.
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

- **Merge on fast gates only:** build, lint, formatting and the cheap policy
  checks. Long suites never block a merge. A PR with an already-FAILED check
  still waits.
- Run an **automatic merger** (see `scripts/fast-merger.sh`). It admin-merges
  any ready PR that passes the fast gates. Authors opt out with a draft or a
  `hold` label.
- **Drafts are for work that is not finished.** Once local verification is
  solid, mark the PR ready immediately. Never leave finished work parked
  waiting for a review round.
- Batch size is free. What matters is **attributability**: every failure must
  map back to a change and its author.
- **Don't let AI attribution trailers leak into commits or PR text** when the
  repo forbids them. The merger refuses such PRs.

## Keeping main usable

- Run the **full suite on main on a schedule** (e.g. hourly) instead of per PR.
- On red, identify the failing test and the culprit change, and route it to
  **the author to fix forward**. Revert only when the fix is slower to verify
  than the revert, or main is unusable for everyone.
- Keep a **green snapshot branch** that advances only when main's full run is
  green. Milestones and releases cut from it, never from main directly.
- If main has been red for more than one full-run cycle on the same failure,
  escalate: revert, or put a frontier lane on it.

## Verification

- **Workers never weaken tests.** No edited or deleted assertions, no longer
  timeouts as a "fix", no blind retries. A flake gets fixed deterministically
  (wait on events or state, not wall-clock time) or quarantined with a ticket
  to its owner.
- **Repeat-run new and reshaped tests** (≥20× for anything racy) before marking
  ready, and **confirm the runs actually executed.** A name filter that matches
  nothing reports N/N green, and a sharded test binary reports a pass from every
  shard that ran zero tests. Use full test paths, disable sharding, and check
  that each run's log says a test actually passed.
- **Review sparingly.** One independent review only for hard,
  durability-critical or first-of-kind changes. Findings get fixed forward
  after merge; never do a second review round.
- **The milestone gate is where quality is enforced:** the full suite, the
  held-out suite and the durability checks all green on the snapshot branch.
- **Test compute is a shared, budgeted resource.** Size CI reservations from
  measurements, keep expensive suites off the merge path, and track the
  known-expensive tests explicitly.

## Decisions

- **Never block on the human.** Small calls: the lead decides and notes it on
  the ticket. Big design calls: the orchestrator decides (optionally after a
  second-model critique), logs the call with its rationale and how reversible
  it is, and adds it to the human's review file.
- Batch the questions that really need the human, and ask them one at a time
  with a recommendation. Put findings from research in front of them, not
  opinions.
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
6. Clean up forks and worktrees of merged work. Log anything noteworthy to the
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
- Planners fighting over files. Fix: ownership and one writer per area.
- A swarm avoiding the hard core code. Fix: assign the core explicitly to a
  frontier lane.
- Main drifting red for long stretches, or regression cascades. Fix: the
  attributable routing and snapshot branch above.
- Repeat-run results that tested nothing, and tests quietly weakened.
- Cost blow-ups from auto-merging with no cost cap.
- Human burnout. Keep the human's queue short and asynchronous.

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
