---
name: wholehog
description: "Implement the optimal end-state directly with a clean cutover: replace superseded functionality completely, remove dead code, and avoid shims, migrations, adapters, or interim steps."
---

# Wholehog

Implement the best final change implied by the preceding context. Aim for the correct end-state now, not a transition plan.

## Default Stance

- Prefer the optimal design over the easiest incremental patch.
- Replace superseded behavior completely.
- Leave the codebase simpler after the change, not more layered.

## Clean Cutover

When new code replaces old code, delete the old path entirely:

1. Old functions, modules, components, and routes
2. Compatibility shims and adapters
3. Migration code, dual-read, and dual-write paths
4. Temporary flags or rollout switches kept only for safety
5. Legacy tests, docs, config, and unused dependencies tied to the old approach

## Rules

1. No shortcuts, scaffolding, or intermediate stepping stones.
2. No preserving old APIs or behavior unless the user explicitly asks for compatibility.
3. Update callers to the new design directly.
4. Remove dead code in the same change.
5. If a true clean cutover is blocked by a hard constraint, state it explicitly and take the smallest possible compromise.
