---
name: complexitysmash
description: "Audit a codebase for systemic complexity and simplification opportunities: duplicated business logic, unnecessary abstractions, mixed responsibilities, poor boundaries, pattern drift, indirection without payoff, and modules that should be merged, split, or deleted. Use when the user wants a full-project design pass or says the codebase feels over-engineered, inconsistent, hard to change, or harder than the problem requires. Prefer this over spring-cleaning when the issue is architectural or cross-cutting rather than a smaller cleanup pass."
---

# Complexitysmash

Perform a top-down complexity audit. Focus on why the codebase is hard to change, not just what can be deleted.

## Core Model

- Separate essential complexity from accidental complexity.
- Treat accidental complexity as contagious. If an abstraction leaks, the next layer inherits that mess as a constraint.
- Prefer simplification moves that reduce cognitive load for future work, not just local elegance.
- Gather broadly, report narrowly. Do the full audit internally, but only present the highest-severity findings.

## Positioning

- Use this skill for repo-wide or subsystem-wide simplification work.
- Use `spring-cleaning` when the job is mostly dead code removal, dependency cleanup, or local restructuring.
- Use this skill when the user wants findings, a simplification plan, or a diagnosis of structural drag before editing code.

## Audit Workflow

1. Map the shape of the system.
   Identify major modules, entry points, ownership boundaries, shared flows, and where business rules live.
2. Find complexity hotspots.
   Look for duplication, speculative abstractions, leaky layers, mixed concerns, inconsistent patterns, and state or config sprawl.
3. Trace each hotspot to its root cause.
   Ask what real constraint each abstraction serves, what changes together, and whether the boundary reduces or increases cognitive load. Separate essential complexity from accidental complexity before proposing changes.
4. Prefer simplification over reshuffling.
   Recommend deletion, merging, inlining, narrowing APIs, or splitting responsibilities before introducing new abstractions.
5. Produce prioritized findings.
   Lead with the highest-leverage simplifications, not a complete catalog of nits. Omit low-value observations unless they support a more severe finding.

## Complexity Lenses

Check for these patterns:

1. Duplicated logic
   The same business rule or workflow appears in multiple files, layers, or code paths.
2. Speculative generality
   Interfaces, base classes, extension points, or generic helpers exist without real variation pressure.
3. Indirection tax
   Wrappers, services, adapters, or factories mostly pass data through without reducing coupling or clarifying policy.
4. Mixed responsibilities
   Modules combine policy, orchestration, IO, persistence, formatting, or UI concerns that should change independently.
5. Boundary failure
   Layers leak internal details, modules always change together, or ownership is unclear.
6. Pattern drift
   Similar problems are solved in multiple inconsistent ways, forcing readers to relearn local conventions.
7. State and config sprawl
   Flags, modes, options, or dependency injection patterns create more branches than value.
8. Abstraction inversion
   The supposedly reusable layer is harder to understand than the concrete use cases it was meant to simplify.

## Decision Rules

- Prefer concrete code until multiple real use cases force a shared abstraction.
- Prefer one obvious path over several slightly different frameworks for the same job.
- If two modules always change together, question the boundary.
- If an interface has one implementation and no substitution pressure, question the interface.
- If a layer only renames fields or forwards calls, collapse it unless it protects a real boundary.
- Separate policy from plumbing. Keep domain rules away from transport, storage, rendering, and framework glue.

## Output Format

Present findings first as a concise list ordered by severity.

- Prefer a short top-N list over exhaustive coverage.
- Each finding should be 1-2 sentences.
- Include the scope or location inline.
- State the core complexity problem and the simplification move in the same short entry.
- Do not turn the report into a long plan or essay.
- Avoid preamble, methodology recap, and long summaries unless the user asks for them.

If useful, end with a very short next-step recommendation, but keep the main output focused on the severity-ordered findings list.

## Relationship To Other Skills

- `spring-cleaning`: use for smaller-scale cleanup and subtraction.
- `wholehog`: use after this audit when the user wants the clean end-state implemented directly.
