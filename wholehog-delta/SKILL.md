---
name: wholehog-delta
description: "Critique a specific implementation, design, plan, feature, document, or repo state against the optimal wholehog end-state. Use when the user wants a concise scored report of what is good, what needs improving, the quantified gap to ideal, and the next steps in optimal order."
---

# Wholehog Delta

Evaluate the current thing against the ideal wholehog end-state: the clean, elegant, final design with no unnecessary shims, dead paths, compatibility layers, or milestone-shaped compromises.

## Core Model

- Measure delta to ideal, not whether the current state is acceptable.
- Treat "good enough for now" as below target unless the user explicitly asks for milestone scoring.
- Reward simplicity, coherence, directness, deleted obsolete paths, tight boundaries, and complete end-state execution.
- Penalize partial migrations, adapter layers, duplicated paths, vague ownership, stale docs/tests/config, and designs that preserve old behavior by accident.
- Be concise. Do the deeper reasoning internally and report only the highest-signal findings.

## Wholehog Delta Score

Use `0-100`, where lower is better:

- `0`: No meaningful delta from the ideal wholehog end-state.
- `1-20`: Mostly ideal; only small polish, evidence, or cleanup remains.
- `21-40`: Solid direction, but some important simplification, deletion, or boundary work remains.
- `41-60`: Material gap; implementation is useful but still shaped by compromise, duplication, or unclear design.
- `61-80`: Large gap; the approach likely needs substantial redesign or cutover work.
- `81-100`: Far from ideal; current shape is mostly the wrong endpoint.

Do not inflate or soften the score to be polite. The score is a delta, not a grade.

## Evaluation Workflow

1. Identify the intended ideal.
   Infer the clean final endpoint from the user's goal, surrounding code, product needs, and existing architecture.
2. Inspect the current implementation.
   Look at the actual code, docs, config, tests, UI, or artifact being evaluated. Do not score from intent alone.
3. Compare against the wholehog endpoint.
   Ask what would disappear, merge, simplify, become explicit, or move boundaries if this were already at the ideal endpoint.
4. Quantify the delta.
   Assign one score for the remaining gap, weighted by user impact, architectural drag, correctness risk, and cleanup left behind.
5. Order the next steps.
   Put steps in the sequence that gets to the ideal fastest with the least churn, not in the order of easiest local patches.

## Lenses

Check for:

1. **Endpoint clarity**
   The implementation has one obvious final model rather than multiple competing paths.
2. **Cutover completeness**
   Superseded code, APIs, docs, tests, configs, and flags are removed.
3. **Boundary quality**
   Responsibilities are cleanly placed and callers do not depend on internals.
4. **Behavioral integrity**
   The current behavior matches the intended final contract, not just the next milestone.
5. **Simplicity**
   The code or design is easier to understand after the change than before it.
6. **Evidence**
   Tests, benchmarks, screenshots, traces, or docs prove the important claims.
7. **Operational readiness**
   Errors, edge cases, observability, deployment, and maintenance paths fit the final design.

## Output Format

Return a concise numbered report:

1. `Wholehog Delta Score: N/100`
   One sentence explaining the main reason for the score.
2. `Good`
   2-4 bullets on what is already aligned with the ideal endpoint.
3. `Needs Improving`
   2-5 bullets on the most important remaining gaps.
4. `Next Steps`
   Numbered steps in optimal order, each phrased as a concrete action.

Keep bullets short and specific. Include file paths or concrete scopes when relevant. Avoid long methodology, generic praise, and exhaustive nit lists.

## Relationship To Other Skills

- `wholehog`: use when the user wants the clean end-state implemented.
- `complexitysmash`: use when the main request is a broader architecture simplification audit.
- `performancesmash`: use when the main request is performance diagnosis.
