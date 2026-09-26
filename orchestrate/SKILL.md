---
name: orchestrate
description: Run large multi-phase work as an Opus 5.5 orchestrator driving two
  worker engines — Opus 5.5 subagents for judgment work and Devin SWE-2 High via
  devin-harness-run for easy/medium specced tasks — with tight briefs,
  ground-truth review and verified hand-offs. Use for refactors, migrations, UI
  builds, or any work >~3 phases or >~500 LOC of change.
---

# Orchestration

You are the architect, reviewer, and integrator. Workers implement. Delegation
is one level deep: you dispatch workers, and workers never dispatch.

## Your judgment

This skill gives defaults, not a script. For example:
- Discard worker output that isn't good enough rather than patching it. Then
  retry with a better brief, move the unit to Opus, or write it yourself.
- Re-split units, re-order phases, switch a unit between Opus and Devin, or
  stop a worker that's going sideways.

## Models

- Every Claude session is Opus 5.5 at `high` effort: you and every worker. No
  other Claude model. Set it once with `"effortLevel": "high"` in
  settings.json; workers run at the session's level.
- Two worker engines. Nothing else gets dispatched.

| Worker | Use for |
|---|---|
| Opus 5.5 subagent | Anything needing judgment or taste: design, deep RCA, cross-cutting contracts, UI/UX, copy, security-sensitive changes, and any unit too ambiguous for a spec file. |
| Devin SWE-2 High (`devin-harness-run`) | Easy/medium tasks with a crisp spec, known file scope and a checkable "done when". Free, so prefer it whenever a unit fits. |

## Protect the Claude budget

Claude usage is the scarce resource; Devin is free.
- You plan, brief, sniff diffs and decide. Don't grind out bulk diffs yourself.
- Default to Devin for: rebases and conflict resolution, fixture re-blesses,
  lint/fmt/deps rounds, CI failures with a known cause, culprit-finding on a
  red main, stale-ticket sweeps, mechanical refactors and renames, docs
  sweeps, and second-opinion reviews.
- Read report files and final summaries, not transcripts or scrollback.

## Driving the workers

### Opus 5.5 — Agent tool
```
Agent(model: "opus", run_in_background: true, description: "<unit>", prompt: <brief>)
```
Completion arrives as a notification; don't poll. Continue a finished worker
with SendMessage (see *Reusing a worker*).

### Devin SWE-2 High — devin-harness-run
The spec is a FILE; the report file it names is the deliverable:
```sh
devin-harness-run --cd <dir> --spec <spec.md> --log <dir>/devin-<task>.log
```
- Launch it backgrounded (Bash `run_in_background: true`); completion arrives
  as a task notification. Don't chain runs, don't poll.
- Unique spec/log files per task. Read `<log>.final` and the report file.
- Each task works in its own fork/worktree per the repo's checkout rules.
- Keep the wrapper's default model; don't pass `--model`.
- A run killed by a transient connection error: resume it with
  `--resume <old log>` and a one-line "continue" spec.

### Reusing a worker
What you can see: each Opus completion notification reports the worker's
tokens, tool uses and duration; ListAgents shows busy/idle; `/tasks` shows
model and effort. Nothing tells you how far main has moved under a worker. So
when you dispatch, record each worker's unit, files, last-reported tokens and
finish time.

Rule of thumb:
- **Reuse** (SendMessage, or Devin `--resume`) only for a follow-up on the
  unit the worker just did: its own CI failure, review findings on its PR, a
  rebase of its branch, the next slice of the same files.
- **Start fresh** for a new unit, for changed instructions, and for an Opus
  worker whose last report was past ~250k tokens or that sat idle past the
  prompt-cache window. A resumed turn then re-reads the whole context
  uncached, and a fresh worker with a good brief is usually cheaper.
- Devin is free, so for Devin only the instruction rule applies: one
  `--resume` round for the same task, fresh spec otherwise.
- Never interrupt a working worker because its context grew. Fix its scope or
  direction instead.

## Briefs and specs (the quality lever)

Every worker brief/spec contains:
- exact scope, and files to READ first (including the repo's worker-rules
  file, if it has one);
- numbered build steps;
- **hard file-ownership boundaries** (may-edit / may-NOT-edit);
- the gates to run, with expected counts;
- the VCS boundary: who commits, who pushes, who opens the PR;
- required OUTPUT sections (files changed, gate results, what fought you,
  unresolved) written to a named report file;
- known traps (path-depth changes, lockfile rules, framework quirks);
- the repo's attribution rule, stated outright. Claude workers add AI
  co-author trailers by default, so a repo that forbids them must say so in
  the brief;
- "You implement; do not spawn subagents. A question you can't settle within
  scope goes in the report's last paragraph; otherwise decide and continue."

For Opus UI briefs, also give the taste constraints: reference
screens/components to match, design tokens, and which skills to load.

## Phases

- Prefer a clean cutover to the end state. Stage behind a flag only when live
  state or users need protecting, and delete the old path within the same
  work.
- Scaffold shared structure yourself, sequentially, so parallel units are
  mechanical. Each worker writes only its own files; shared files are yours.

## Verifying worker output

- Per unit: the worker's gate results plus your sniff of the diff.
- At each phase end, run a gate battery **yourself, unsandboxed**. Worker
  sandboxes lie (blocked listeners, no `ps`, no network, read-only git). "13
  failures, all sandbox" is usually true — verify it, don't trust it.
- Include at least one gate outside the test runner: a real build, a real
  boot, a real image. These catch what green suites structurally cannot
  (missing COPY, lockfile drift, workspace-member gaps). For UI, actually look
  at it (run the app, screenshot); don't sign off on UI from a diff.
- Check the actual artifacts (processes, output files, tree, branch) before
  believing "nothing happened" or "done".

## Reviews

When a unit gets a review:
- Review **against ground truth** (the untouched originals), not the diff's
  own claims. Ask for severity + file:line + the divergent original line. Try
  to *refute* correctness.
- Cross engines: an Opus worker reviews Devin's diff; Devin can review an Opus
  diff. UI/taste reviews are yours or an Opus worker's, never Devin's.
- Cross-cutting findings (middleware, mounts, shared config) are yours to fix
  at the scaffold level; unit findings go back to the unit's worker or get
  fixed in place.

## Honesty rules

- Stub what you can't run live (no keys, no target platform) and label it
  PENDING with the reason. Never fake a gate.
- "Keep and report" beats improvising when a deletion candidate is still
  referenced.
- Tests get PORTED, never silently dropped; account for the delta.

## Recovery patterns

- Worker couldn't touch git → you stage; renames re-detect at commit.
- Hand-edited lockfile → discard, re-resolve from the registry, diff for drift.
- Live behavior differs from repo behavior → suspect a divergent deployed copy
  or cache before suspecting the code; check the live surface for ground truth.
