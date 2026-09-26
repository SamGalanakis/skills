---
name: orchestrate
description: Run large multi-phase work as an orchestrator (Fable 5.1) driving
  workers — Opus 5.5 subagents at high effort, and Devin SWE-2 High via
  devin-harness-run for easy/medium specced tasks — with per-phase gates the
  orchestrator verifies personally. Use for refactors, migrations, UI builds,
  or any work >~3 phases or >~500 LOC of change.
---

# Orchestration

You are the architect, reviewer, and integrator. Workers implement. You never
merge work you haven't personally verified.

## Your judgment

This skill gives defaults, not a script. For example:
- Discard worker output that isn't good enough rather than patching it. Then
  retry with a better brief, escalate to Opus, or write it yourself.
- Re-split units, re-order phases, switch a unit between Opus and Devin, or
  stop a worker that's going sideways.

## Routing

Two worker engines. Nothing else gets dispatched.

| Worker | Effort | Use for |
|---|---|---|
| Opus 5.5 subagent | always `high` | **Default implementer.** Anything needing judgment or taste: UI, design, UX, front-end, copy, architecture-adjacent work — and any unit too ambiguous for a spec file. |
| Devin SWE-2 High (`devin-harness-run`) | fixed | Easy/medium tasks with a crisp spec, known file scope and a checkable "done when": mechanical refactors, renames, known-root-cause test fixes, bulk clear-spec code, docs sweeps, independent reviews. Free — prefer it whenever a unit fits. |

- **Speccable and easy/medium → Devin. Everything else → Opus.** Since the
  easy work leaves to Devin, every Opus worker runs at `high`.
- Keep your own token burn low: plan, brief, verify, fix surgically. Don't
  grind out bulk diffs yourself.

## Driving the workers

### Opus 5.5 — subagents
Dispatch Claude workers through Workflow `agent()`, which can set effort:
```js
agent(brief, { model: 'opus', effort: 'high', label: 'ui:settings-panel' })
```
Never omit `model`/`effort` on worker calls. A single unit is fine as a
one-agent workflow.

### Devin SWE-2 High — devin-harness-run
The spec is a FILE; the report file it names is the deliverable:
```sh
devin-harness-run --cd <dir> --spec <spec.md> --log <dir>/devin-<task>.log
```
- Launch it backgrounded (Bash `run_in_background: true`) — completion arrives
  as a task notification. Don't chain runs, don't poll.
- Unique spec/log files per task. Read `<log>.final` and the report file, not
  the scrollback.
- Each task works in its own fork/worktree per the repo's checkout rules.
- One `--resume` fix round is fine for "continue the same task". When the
  instructions CHANGE (new requirement, policy change), start a fresh session
  with a self-contained spec — resumed sessions can ignore new instructions.
  If it misses twice, take the task back to an Opus unit.

## Briefs and specs (the quality lever)

Every worker brief/spec contains: exact scope, files to READ first, numbered
build steps, **hard file-ownership boundaries** (may-edit / may-NOT-edit), the
gates to run with expected counts, the VCS boundary (who commits, who pushes),
and required OUTPUT sections (files changed, gate results, what fought you,
unresolved). State known traps explicitly (path-depth changes, lockfile rules,
framework quirks). For Opus UI briefs, also give the taste constraints:
reference screens/components to match, design tokens, and which skills to
load.

## Phases and gates

- Order phases so work lands independently: additive + flag-gated beats
  big-bang; delete last, after replacements are proven.
- Freeze shared contracts BEFORE any parallel fan-out.
- Every phase ends with a gate battery **you run yourself, unsandboxed**: agent
  sandboxes lie (blocked listeners, no `ps`, no network, read-only git). "13
  failures, all sandbox" is usually true — verify it, don't trust it.
- Include at least one gate outside the test runner: a real build, a real
  boot, a real image. These catch what green suites structurally cannot
  (missing COPY, lockfile drift, workspace-member gaps). For UI: actually look
  at it (run the app, screenshot) — don't sign off on UI from a diff.

## Fan-out (parallel work)

- Only with disjoint file domains; each worker writes its OWN files, shared
  files belong to you. Scaffold first (sequentially) so fan-out slots are
  mechanical.
- Opus units: Workflow `pipeline()` so each unit flows into its review without
  barriers. Devin units: parallel background `devin-harness-run` processes,
  each in its own file domain.
- Check the actual artifacts (processes, output files, tree) before believing
  "nothing happened" — work often completed anyway.

## Review lanes

- Review each unit **against ground truth** (the untouched originals), not
  against the diff's own claims. Ask for severity + file:line + the divergent
  original line. Try to *refute* correctness — green suites hide real defects.
- You do final reviews. For an independent second perspective, review across
  engines: an Opus worker reviews Devin's diff, and Devin can review an Opus
  unit's diff. UI/taste reviews are yours or an Opus worker's, never Devin's.
- Cross-cutting findings (middleware, mounts, shared config) are yours to fix
  at the scaffold level; unit findings go back to the unit or get fixed in
  place.

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
