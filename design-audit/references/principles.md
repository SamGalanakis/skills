# Design Audit Principles

Distilled guidance behind `design-audit`. Read this only when you need a deeper mental model for the critique.

## Norman

- Make possible actions legible.
- Show system state quickly and continuously.
- Use mappings that explain cause and effect.
- Do not confuse hidden mechanics with reduced complexity.

## Nielsen

- Keep users oriented: where they are, what changed, what is available next.
- Replace memory with visibility.
- Prevent high-cost errors first.
- Make recovery obvious, local, and specific.

## Krug

- The next click should feel self-evident.
- Pages should answer: what is this, what can I do here, why should I care?
- If users must stop to decode navigation or labels, the design is already slow.

## Rams

- Useful beats decorative.
- Remove everything that steals attention from the core job.
- Precision in small details signals trust in larger ones.

## Tufte

- Clutter is not neutral; it hides relationships and weakens comparison.
- Dense can be good when it improves scanning and comparison.
- Every visual element should either inform, orient, or support action.

## Wroblewski

- Inputs are work. Remove fields, choices, and confirmations aggressively.
- Put help near the field, not in a detached explainer.
- Let mobile constraints reveal what the flow actually needs.

## Cooper

- Design around goals, not around available features.
- Separate browsing from editing when they compete for attention.
- Different users need different interaction speeds; support both without mixing them badly.

## Practical Severity Rules

- Highest severity: users cannot tell what to do, cannot complete the main task, or can complete it only with hesitation.
- Next: the structure is wrong, so local cleanup will not fix the confusion.
- Next: hierarchy, copy, and layout weaken scanning or misdirect attention.
- Lowest: polish issues that do not materially change comprehension, trust, or throughput.
