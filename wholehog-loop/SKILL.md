---
name: wholehog-loop
description: "Iteratively drive an implementation to a target wholehog score. The main agent orchestrates: an implementation subagent does each wholehog pass, an independent scoring subagent scores it, and the loop repeats until the score meets the user's named goal or an unpassable blocker is hit. Use when the user wants something improved repeatedly until it reaches a specific wholehog score they set (e.g. loop to 95)."
---

# Wholehog Loop

Drive a task to a target quality bar by alternating implementation passes with independent scoring, until the score meets the user's goal or a real blocker stops progress. The main agent only orchestrates — it never edits or scores directly. Each role is a separate subagent so the builder and the judge stay independent.

## Roles

- **Main agent (orchestrator).** Establishes scope, runs the loop, decides against the goal, relays the scorer's next steps to the implementer, detects blockers, and writes the final summary. It does not write code or assign scores itself.
- **Implementation subagent.** Does each `wholehog` pass against the real repo. Keep one implementer across iterations (continue it with each new work list) so it retains what it already built and why.
- **Scoring subagent.** Independently scores the current state with the `wholehog-score` skill. Spawn a **fresh** one every iteration so the judge never anchors on prior work or its own past scores.

## Required Input

- **A target score (0–100).** The user must name it — e.g. "wholehog-loop to 95". If no number is given, ask for one before starting (90–95 is a typical bar) and do not proceed without it.
- **Scope.** The obvious in-context task, or whatever the user named before/after the skill invocation. State it in one line so it does not drift across iterations.
- *(optional)* **Iteration cap.** Default `6`. The user may override. This is a runaway guard, not a goal.

## The Loop

Each iteration, the orchestrator:

1. **Delegates implementation.** Hand the implementation subagent the scope, constraints, and the current work list (the scorer's *Needs Improving* / *Next Steps* from last iteration), instructing a `wholehog` pass — clean cutover, no shims, delete superseded paths, highest-ROI gaps first.
2. **Delegates scoring.** Spawn a fresh scoring subagent that inspects the real state and returns its `wholehog-score` report.
3. **Decides.**
   - Score **≥ goal** → stop, success summary.
   - A **blocker** is hit → stop, blocked summary.
   - Otherwise → carry the report's *Needs Improving* / *Next Steps* into the next iteration as the implementer's work list.

On the first iteration: if an implementation already exists, score a baseline first (scoring subagent) before delegating any changes; if building from scratch, delegate the initial implementation pass, then score.

Announce each iteration to the user as a single line — `Iteration K: N/100 (goal G)` — so a long loop stays visible.

## Delegating Implementation

Give the implementation subagent:

- The one-line scope and the user's actual constraints.
- The current work list — the scorer's last *Needs Improving* / *Next Steps*, in optimal order.
- The `wholehog` stance: implement the end-state directly, remove dead paths in the same change, no interim scaffolding.
- An instruction to report back what it changed (files touched, what was deleted/replaced) so you can assemble the final summary.

Keep the same implementer across iterations (continue it with the new work list) rather than respawning, so it does not re-derive context each pass.

## Delegating Scoring

Spawn a fresh scoring subagent each iteration. This keeps the judge independent of the builder and the main context lean — only the structured report comes back.

Pass it:

- The one-line scope and the user's actual constraints (so it scores task-relative, not maximalist).
- Pointers to the **actual code/artifact** to inspect — changed files, paths, the diff — and an instruction to read them. It scores from the real state, not from anyone's description.
- An instruction to apply the `wholehog-score` skill and return its full report (score, Good, Needs Improving, Next Steps).

Do **not** pass:

- Any target or hoped-for score.
- The implementer's self-assessment, or the previous iteration's score. Keep each scoring unanchored — the orchestrator tracks the trajectory itself and reports it at the end.

## Blockers

Stop and report blocked when continuing will not productively close the gap:

- **Stall.** Best score fails to improve by a meaningful margin (≈ +2 or more) across two consecutive iterations that genuinely addressed the prior next steps. Small fluctuations are scorer noise, not progress.
- **Hard constraint.** The only remaining gap requires something disallowed or unavailable — a compatibility layer the user wants kept, a missing dependency/credential/API, an external system, or a product decision that is not yours to make.
- **Ceiling below goal.** The clean end-state achievable within the task's real constraints tops out below the target — the goal was set higher than the scope can reach without violating it.
- **Iteration cap reached** without hitting the goal.
- **Regression risk.** Another pass would harm correctness or delete something the user needs.

## Output

**On success:**

- Header: `Reached N/100 (goal G) in K iterations.`
- Trajectory: the score sequence, e.g. `62 → 81 → 93 → 96`.
- A concise summary of what actually changed across all iterations, assembled from the implementers' reports, grouped logically, with key file paths. This is a changes summary, not a re-print of the score report.
- One line on anything intentionally left undone (above ~92 returns diminish — say so if relevant).

**On blocker:**

- Best score reached, the trajectory, and the specific blocker.
- The smallest thing that would unblock it: lower the goal, expand the scope, or relax a named constraint — and the score ceiling you expect under the current scope.
- What was accomplished so far.

## Guardrails

- **Orchestrator stays hands-off.** The main agent does not edit code or assign scores — it only delegates, decides, and summarizes. Implementation and scoring are always separate subagents.
- **Never game the judge.** Do not tell the scorer what to score, do not feed it the implementer's self-assessment, and do not let the implementer satisfy the letter of a "next step" without the underlying improvement.
- **One independent scoring per iteration**, always by a fresh subagent.
- **Hold to wholehog principles** in every implementation pass — clean cutover, remove dead paths, no interim scaffolding. The loop drives toward the end-state, not a pile of patches.
- **Respect the done-line.** If the score plateaus near the top with no constraint requiring more, treat it as a ceiling and surface it rather than churning.

## Relationship To Other Skills

- `wholehog`: the stance the implementation subagent takes each iteration.
- `wholehog-score`: the rubric the scoring subagent applies each iteration.
- `complexitysmash` / `performancesmash`: use directly when the request is a one-shot audit rather than a drive-to-target loop.
