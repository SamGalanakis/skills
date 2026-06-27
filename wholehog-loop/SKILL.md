---
name: wholehog-loop
description: "Iteratively drive an implementation to a target quality bar. By default the loop uses wholehog-score and a numeric target, but the user may provide an alternate critique method or stopping criterion. The main agent orchestrates implementation and independent critique passes until the criterion is met or a real blocker stops progress."
---

# Wholehog Loop

Drive a task to a target quality bar by alternating implementation passes with independent critique, until the stopping criterion is met or a real blocker stops progress. By default, the critique is `wholehog-score` and the stopping criterion is a numeric score goal. The user may instead name a different critique method, rubric, or stop condition. The main agent only orchestrates — it never edits or judges directly. Each role is a separate subagent so the builder and the judge stay independent.

## Roles

- **Main agent (orchestrator).** Establishes scope, runs the loop, decides against the criterion, relays the critique report's next steps to the implementer, detects blockers, and reports progress to the user in the standardized format (see Reporting). It does not write code or assign outcomes itself.
- **Implementation subagent.** Does each `wholehog` pass against the real repo. Keep one implementer across iterations (continue it with each new work list) so it retains what it already built and why.
- **Critique subagent.** Independently critiques the current state. By default it uses the `wholehog-score` skill; if the user provides another critique method or stopping criterion, use the appropriate rubric/tool. Spawn a **fresh** one every iteration so the judge never anchors on prior work or its own past findings.

## Required Input

- **Stopping criterion.** Default: a target wholehog score (0–100), e.g. "wholehog-loop to 95". The user may instead provide an alternate critique/stopping criterion, e.g. "loop until the reviewer finds no P0/P1 issues", "loop until the Playwright screenshots are clean", or "loop until the security critique passes". If the user provides neither a target score nor a criterion, ask for one before starting.
- **Scope.** The obvious in-context task, or whatever the user named before/after the skill invocation. State it in one line so it does not drift across iterations.
- *(optional)* **Iteration cap.** Default: none. The user may set one as a runaway guard; when unset, continue until the stopping criterion is met or a real blocker stops progress.

## The Loop

Each iteration, the orchestrator:

1. **Delegates implementation.** Hand the implementation subagent the scope, constraints, and the current work list (the critique report's *Needs Improving* / *Next Steps* from last iteration), instructing a `wholehog` pass — clean cutover, no shims, delete superseded paths, highest-ROI gaps first.
2. **Delegates critique.** Spawn a fresh critique subagent that inspects the real state and returns a report under the selected critique method. Default critique is `wholehog-score`.
3. **Decides.**
   - Criterion met → stop, success summary.
   - A **blocker** is hit → stop, blocked summary.
   - Otherwise → carry the report's *Needs Improving* / *Next Steps* (or equivalent critique output) into the next iteration as the implementer's work list.

On the first iteration: if an implementation already exists, run a baseline critique first before delegating any changes; if building from scratch, delegate the initial implementation pass, then critique.

After every critique — before deciding whether to continue — print the standardized **iteration card** (see Reporting) so the user watches progress live. In default score mode, use the score card. In alternate-criterion mode, use the alternate criterion card.

## Delegating Implementation

Give the implementation subagent:

- The one-line scope and the user's actual constraints.
- The current work list — the critique report's last *Needs Improving* / *Next Steps*, in optimal order.
- The `wholehog` stance: implement the end-state directly, remove dead paths in the same change, no interim scaffolding.
- An instruction to report back what it changed (files touched, what was deleted/replaced) so you can assemble the final summary.

Keep the same implementer across iterations (continue it with the new work list) rather than respawning, so it does not re-derive context each pass.

## Delegating Critique

Spawn a fresh critique subagent each iteration. This keeps the judge independent of the builder and the main context lean — only the structured report comes back.

Pass it:

- The one-line scope and the user's actual constraints (so it evaluates task-relative, not maximalist).
- Pointers to the **actual code/artifact** to inspect — changed files, paths, the diff — and an instruction to read them. It scores from the real state, not from anyone's description.
- The selected critique method:
  - Default: apply the `wholehog-score` skill and return its full report (score, Good, Needs Improving, Next Steps).
  - Alternate: apply the user's named rubric/tool/criterion and return a clear verdict, evidence, Good, Needs Improving, and Next Steps.

Do **not** pass:

- Any target or hoped-for outcome.
- The implementer's self-assessment, or the previous iteration's score/verdict. Keep each critique unanchored — the orchestrator tracks the trajectory itself and reports it at the end.

## Blockers

Stop and report blocked when continuing will not productively close the gap:

- **Stall.** Best observed score/verdict fails to improve meaningfully across two consecutive iterations that genuinely addressed the prior next steps. In score mode, treat ≈ +2 or more as meaningful; in alternate-criterion mode, require substantive evidence movement toward the criterion. Small fluctuations are judge noise, not progress.
- **Hard constraint.** The only remaining gap requires something disallowed or unavailable — a compatibility layer the user wants kept, a missing dependency/credential/API, an external system, or a product decision that is not yours to make.
- **Ceiling below goal.** The clean end-state achievable within the task's real constraints tops out below the target/criterion — the goal was set higher than the scope can reach without violating it.
- **User-provided iteration cap reached** without meeting the criterion.
- **Regression risk.** Another pass would harm correctness or delete something the user needs.

## Reporting

The orchestrator owns all user-facing output. Use the score templates for the default wholehog-score mode. Use the alternate criterion templates when the user provides a different critique/stopping condition. Keep every field terse; fill `{…}` and drop nothing.

### Iteration card

Print after each critique, before the continue/stop decision.

Default score mode:

```
Iteration {K} — Score {N}/100   ·   goal {G}   ·   {+Δ vs prev | baseline}   ·   {status}
Trajectory: {s1 → s2 → … → N}
• Done this pass: {what the implementer changed, one line}
• Top gaps:       {1–3 terse bullets of what's holding the score down}
• Next fixes:     {numbered, optimal order, each with expected +delta if known}
```

`{status}` is one of: `on track ↑` · `slowing →` · `goal met ✓` · `blocked ✗`. On the baseline iteration write `baseline` in the delta slot and omit *Done this pass*.

Alternate criterion mode:

```
Iteration {K} — Criterion {criterion}   ·   verdict {met | not met}   ·   {status}
Trajectory: {verdict1 → verdict2 → … → verdictK}
• Done this pass: {what the implementer changed, one line}
• Top gaps:       {1–3 terse bullets of what's holding the criterion back}
• Next fixes:     {numbered, optimal order, each with expected impact if known}
```

### Final — goal reached

Default score mode:

```
✓ Wholehog Loop complete — {N}/100 (goal {G}, {K} iterations)
Trajectory: {s1 → … → N}

What changed
• {grouped changes across all iterations, with key file paths}

Left undone: {one line, or "nothing material — at the done-line"}
```

Alternate criterion mode:

```
✓ Wholehog Loop complete — criterion met ({criterion}, {K} iterations)
Trajectory: {verdict1 → … → met}

What changed
• {grouped changes across all iterations, with key file paths}

Left undone: {one line, or "nothing material — at the done-line"}
```

### Final — blocked

Default score mode:

```
✗ Wholehog Loop blocked — best {N}/100 (goal {G}, {K} iterations)
Trajectory: {s1 → … → N}

Blocker: {which blocker, with specifics}
To unblock: {smallest move — lower goal to ~{X} / expand scope / relax {constraint}}; expected ceiling ~{Y} under current scope.

Accomplished so far
• {grouped changes, with key file paths}
```

Alternate criterion mode:

```
✗ Wholehog Loop blocked — criterion not met ({criterion}, {K} iterations)
Trajectory: {verdict1 → … → verdictK}

Blocker: {which blocker, with specifics}
To unblock: {smallest move — expand scope / relax {constraint} / provide {missing input}}; expected ceiling under current scope: {ceiling if known}.

Accomplished so far
• {grouped changes, with key file paths}
```

The *What changed* / *Accomplished so far* list is a changes summary assembled from the implementers' reports — not a re-print of the score reports.

## Guardrails

- **Orchestrator stays hands-off.** The main agent does not edit code or assign scores/verdicts — it only delegates, decides, and summarizes. Implementation and critique are always separate subagents.
- **Never game the judge.** Do not tell the critique subagent what outcome to reach, do not feed it the implementer's self-assessment, and do not let the implementer satisfy the letter of a "next step" without the underlying improvement.
- **One independent critique per iteration**, always by a fresh subagent.
- **Hold to wholehog principles** in every implementation pass — clean cutover, remove dead paths, no interim scaffolding. The loop drives toward the end-state, not a pile of patches.
- **Respect the done-line.** If the score plateaus near the top with no constraint requiring more, treat it as a ceiling and surface it rather than churning.

## Relationship To Other Skills

- `wholehog`: the stance the implementation subagent takes each iteration.
- `wholehog-score`: the default rubric the critique subagent applies each iteration unless the user names another criterion.
- `complexitysmash` / `performancesmash`: use directly when the request is a one-shot audit rather than a drive-to-target loop.
