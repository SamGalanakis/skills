---
name: ritualsmash
description: Cut ritual overhead from agent instructions, briefs, workflows and gates - steps that cost time, tokens, or wall clock but catch no failure that something else does not already catch. Targets provenance ceremony (seals, manifests, hash inventories, receipts), duplicate verification, repeat runs for confidence, approval gates on reversible actions, hold-until-complete landings, readiness checks before work, acknowledgement and narration, bookkeeping that blocks action, and rules that spread between agents by imitation. Default verdict is axe; it edits the shared rule files directly and reports what it cut. Use when the user says agents are slow, bureaucratic, doing paperwork, over-verifying, not landing, or asks to cut process, rituals, or ceremony.
---

# Ritualsmash

Agents invent process. A step that sounds responsible ("seal the inputs",
"verify ancestry", "re-run to confirm") costs nothing to propose and nobody
questions it. So it spreads, from one lane's report to the shepherd's
checklist to the next lane's brief. Each ritual looks cheap. Together they
are why work takes a day instead of an hour and why finished commits sit
unlanded.

**Every step must justify itself; if it can't, it goes.** Cutting process is
reversible: if a cut turns out to matter, the failure shows up and the step
comes back with a real reason. Keeping a ritual costs something on every run,
forever. So when in doubt, cut it.

## The test

For every step, rule, gate and artifact, ask: **what failure would ship
without it that nothing else catches?**

Name the failure concretely: a red main, a wrong number, a lost write, an
unsound acceptance. "Integrity", "traceability", "to be safe" and "for the
record" are not failures. If tests, the land step, the type checker, git,
content addressing, the scheduled full run or review already catch it, the
step catches nothing. **No named failure: axe.** If only part of it catches
something: shrink it to that part.

## Common rituals

| Ritual | Looks like | Cut to |
|---|---|---|
| **Provenance ceremony** | input seals, frozen trees, union manifests, hash inventories, receipt files, patch-id or byte-equality checks, ancestry proofs | nothing; evidence is the tests run, the land exit code, the SHA |
| **Duplicate verification** | the same suite run by worker, reviewer and land step; checking that a check ran | one pass per check, wherever it is cheapest |
| **Repeat runs** | "ran it 3x green", re-running after a clean rebase, re-gating because main moved | one run; a rebase needs only a build; fix flakes rather than re-running until green |
| **Hold until complete** | atomic pairs, "land when everything is ready", finished commits parked for a sibling | land each slice as it qualifies; only the final cutover is atomic |
| **Asking first** | approval for a revertable change, a retry, a scratch worktree, a call already within the agent's authority | do it, then say in one line what was done and how to undo it |
| **Readiness ritual** | validators, inventories, preflight reports, plans before touching code | start; a missing prerequisite fails fast on its own |
| **Narration** | acknowledgement messages, progress reports, restating the brief, evidence packets | five lines or fewer per message; one short report, numbers first |
| **Paper blocks work** | waiting on a ticket, ledger line or sign-off before the next step | write it afterwards, or skip it |
| **Measuring guesses** | benchmarks of a suspected hot spot, attribution studies | profile first; measure only the change made |
| **Design churn** | design, NO-GO, then a new design lane on the same question | one decision; revisit only on new data |
| **Rule contagion** | a ritual one agent invented, enforced on others by a reviewer, shepherd or template | strike it everywhere it spread |

## The short list that stays

Keep these, but scope them:

- tests that execute and would fail on a real bug;
- the land step's build;
- soundness and trust-boundary checks;
- inputs frozen during a measurement, and only during it;
- cost caps;
- asking before an action that is irreversible or visible outside the project.

Everything else is on the table, including rules that look like policy. A
rule the user wrote explicitly stays; cut its ritual around it and flag it
if the rule itself looks like the cost.

## Workflow

1. **Read what agents receive and what they do.** Shared instructions,
   launcher preambles, brief templates, reviewer and shepherd prompts, land
   scripts, and a sample of recent reports, messages and traces. A quick grep
   for ritual words (seal, receipt, manifest, ancestry, frozen, readiness,
   re-run, acknowledged, waiting on) finds most of it. Look for finished work
   that never landed.
2. **Cut.** Edit the shared rule files directly: delete the ritual and, where
   agents will reinvent it, add one line forbidding it. Put rules where every
   agent reads them, not in messages to individual agents. Remove the
   enforcement too (the reviewer or shepherd line that demands it).
3. **Tell running agents**, one line each: stop doing X, land what you have.

Don't build an inventory, a scoring table or a plan first. That is the
ritual this skill exists to remove.

## Output

A short report after the cuts:

- the cost found, in one or two lines (wall clock, tokens, or work held up);
- what was cut and where, one line each, with the new rule text if any;
- anything left alone that looked like a cost, with the one-line reason (for
  example, the user wrote it).

## Relationship To Other Skills

- `firehose` sets the operating stance; `ritualsmash` removes drift away from it.
- `testsmash` judges individual tests; `ritualsmash` judges the process around
  them: who runs them, how often, and what waits on them.
- `groundhog` mines sessions for any friction and recommends; `ritualsmash`
  targets self-imposed process and cuts it.
