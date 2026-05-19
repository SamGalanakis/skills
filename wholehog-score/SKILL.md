---
name: wholehog-score
description: "Score a specific implementation, design, plan, feature, document, or repo state against the optimal wholehog end-state. Use when the user wants a concise scored report of what is good, what needs improving, the trajectory since the last run, and the next steps in optimal order."
---

# Wholehog Score

Evaluate the current thing against the ideal wholehog end-state: the clean, elegant, final design with no unnecessary shims, dead paths, compatibility layers, or milestone-shaped compromises.

## Core Model

- Score how close the current thing is to the ideal end-state.
- The ideal is task-relative, not universal. It is the simplest design that meets the user's actual constraints — not a maximalist build. For a prototype the ideal is different than for a shipping system; infer scope from the request.
- Treat "good enough for now" as below ideal unless the user explicitly asks for milestone scoring.
- Reward simplicity, coherence, directness, deleted obsolete paths, tight boundaries, and complete end-state execution.
- Penalize partial migrations, adapter layers, duplicated paths, vague ownership, stale docs/tests/config, and designs that preserve old behavior by accident.
- Be concise. Do the deeper reasoning internally and report only the highest-signal findings.

## Wholehog Score

Use `0-100`, where **higher is better** (`100` = ideal end-state).

- `100`: No meaningful gap from the ideal end-state.
- `90-99`: Mostly ideal; only small polish, evidence, or cleanup remains. Ship it.
- `70-89`: Solid direction, but some important simplification, deletion, or boundary work remains.
- `50-69`: Material gap; useful but still shaped by compromise, duplication, or unclear design.
- `25-49`: Large gap; the approach likely needs substantial redesign or cutover work.
- `0-24`: Far from ideal; current shape is mostly the wrong endpoint.

Concrete anchors so scores stay calibrated across runs and reviewers:

- **~95**: feature shipped, used in production, one minor cleanup or evidence gap. Practically done.
- **~85**: works end-to-end, but one integration test or one parallel-path cleanup is still missing.
- **~70**: working, but a superseded path still exists alongside the new one, or important behavior is unevidenced.
- **~50**: useful slice, but the design still carries a milestone-shaped compromise (adapter layer, feature flag, dual write).
- **~30**: large rework remaining; current shape is the wrong endpoint even if it functions.
- **~10**: barely on the right path; redesign is the next step.

**Done line.** Above ~92, returns diminish unless the user has a specific SLA, perf budget, or compliance constraint in mind. Say so explicitly when applicable: `Practically done at ~92 — further polish is diminishing returns unless <constraint>.`

Do not inflate or soften the score to be polite. Do not sandbag to look rigorous either. The score is calibration, not a grade.

## Evaluation Workflow

1. State the scope.
   One line up front: what is being evaluated and at what boundary. Prevents drift across re-runs.
2. Identify the intended ideal.
   Infer the clean final endpoint from the user's goal, surrounding code, product needs, and existing architecture. Stay task-relative.
3. Inspect the current implementation.
   Look at the actual code, docs, config, tests, UI, or artifact being evaluated. Do not score from intent alone.
4. Compare against the wholehog endpoint.
   Ask what would disappear, merge, simplify, become explicit, or move boundaries if this were already at the ideal endpoint.
5. Quantify the score.
   Weight by user impact, architectural drag, correctness risk, and cleanup left behind. Calibrate against the concrete anchors above.
6. Show trajectory.
   If you have visibility into a prior score for the same target — through memory, transcript, or a user mention — show `N/100 (was M)` and one line on what closed since then. Progress is the most useful information a re-run can give.
7. Order the next steps.
   Put steps in the sequence that gets to the ideal fastest with the least churn. Annotate each with its expected score delta so the user can prioritize by ROI.

## Lenses

Weight the score across these. When one or two dominate the result, surface that in the score justification.

1. **Endpoint clarity** — one obvious final model, not multiple competing paths.
2. **Cutover completeness** — superseded code, APIs, docs, tests, configs, and flags are removed.
3. **Boundary quality** — responsibilities are cleanly placed; callers do not depend on internals.
4. **Behavioral integrity** — current behavior matches the intended final contract, not just the next milestone.
5. **Simplicity** — easier to understand after the change than before it.
6. **Evidence** — tests, benchmarks, screenshots, traces, or docs prove the important claims.
7. **Operational readiness** — errors, edge cases, observability, deployment, and maintenance paths fit the final design.

## Output Format

Return a concise numbered report:

1. **Header line.**
   `Wholehog Score: N/100 (higher = closer to ideal)`. If a prior score is known, append `(was M, was K …)`.
2. **Scope.**
   One line naming what is being evaluated and at what boundary.
3. **Score justification.**
   One or two sentences answering both: why this score and not 5 higher (what would be missing to score higher), and why this score and not 5 lower (what would be missing if we lost it). Mention the 1–2 lenses that drove the result.
4. **Good.**
   2–4 bullets on what is already aligned with the ideal endpoint.
5. **Needs Improving.**
   2–5 bullets on the most important remaining gaps.
6. **Next Steps.**
   Numbered steps in optimal order, each phrased as a concrete action and annotated with its expected score impact, e.g. `1. Add resume_turn integration test (+4).` Stop the list once the remaining steps drop into diminishing returns.

Keep bullets short and specific. Include file paths or concrete scopes when relevant. Avoid long methodology, generic praise, and exhaustive nit lists.

For scores `95+` the report compresses naturally: header + scope + a single paragraph + one ship-it line is plenty.

## Relationship To Other Skills

- `wholehog`: use when the user wants the clean end-state implemented.
- `complexitysmash`: use when the main request is a broader architecture simplification audit.
- `performancesmash`: use when the main request is performance diagnosis.
