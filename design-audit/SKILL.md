---
name: design-audit
description: Audit a product's UX, UI, information architecture, and interaction model. Use when the user wants a holistic design critique, a numbered severity-ordered list of improvements, or guidance on restructuring screens, flows, navigation, copy, responsiveness, and component patterns before implementation.
---

# Design Audit

Run a top-down UX/UI/product-design critique. Focus on why the interface is hard to understand, hard to navigate, hard to act in, or visually noisy. Report only the highest-leverage improvements.

## Core Stance

Compress these principles into every audit:
- **Norman**: make actions discoverable, keep feedback visible, preserve clear conceptual models, and fit complexity to the task instead of hiding it badly.
- **Nielsen**: prioritize visibility of status, recognition over recall, consistency, error prevention, clear recovery, and minimal but not impoverished interfaces.
- **Krug**: the next step should feel obvious; pages should scan fast; navigation and labels should not require interpretation.
- **Rams**: usefulness beats decoration; details must feel intentional; remove anything that distracts from the job.
- **Tufte**: clutter and confusion are design failures; every visual unit should earn its place; information density should help comparison and comprehension.
- **Luke Wroblewski**: treat input as labor; shorten forms, use sane defaults, reduce branching, and let mobile constraints expose what actually matters.

Be a hard critic, not a polite stylist. Do not get trapped in the current layout or component set. If the product needs a different page structure, interaction model, panel layout, or flow, say so directly.

## Audit Discipline

- Diagnose causes, not just symptoms. Weak spacing often means weak grouping; weak grouping often means weak information architecture.
- Prefer fewer, larger findings. If every note is local, you probably missed the structural problem.
- Judge the interface by task clarity, decision quality, and user confidence, not personal taste.
- Audit novice and expert use separately. Good defaults and clear guidance for one should not block speed for the other.
- Treat hidden complexity as debt. If the UI stays "clean" only by making users remember, hunt, or guess, it is not actually simple.
- If multiple valid interpretations of a screen exist, the screen is under-explained.

## Audit Order

1. **Task fit**
   What is the user trying to accomplish here, and does the screen make that job obvious?
2. **Flow**
   Can users see where to start, what happens next, and how to recover from mistakes?
3. **Architecture**
   Are pages, panels, tabs, sections, and navigation grouped around mental models or around implementation leftovers?
4. **Interaction cost**
   Count clicks, fields, mode switches, hidden actions, precision demands, and memory burden.
5. **Hierarchy**
   Is the primary action unmistakable? Can the eye scan the screen in the right order?
6. **Language**
   Are labels, headings, empty states, errors, and CTA text concrete and specific?
7. **Layout**
   Look for broken alignment, weak spacing rhythm, awkward density, poor grouping, unstable widths, and dead zones.
8. **States**
   Audit loading, empty, error, success, disabled, hover, focus, selection, and destructive moments.
9. **Adaptation**
   Check mobile, tablet, desktop, zoom, keyboard flow, contrast, hit targets, overflow, and reflow.
10. **Consistency**
    Similar problems should look and behave similarly across the product.

## What To Hunt For

Prioritize high-order problems over polish:
- Wrong screen for the job: a dense task buried in a modal, a workflow compressed into one page, or unrelated tasks forced together.
- Wrong container: tabs hiding sequential steps, accordions hiding critical information, cards pretending to be a dashboard, tables used where comparison is impossible, or feed layouts used for task execution.
- Wrong interaction model: actions hidden in hover states, gesture-only controls, ambiguous icons, too many per-item menus, or controls far from the thing they affect.
- Wrong emphasis: secondary stats or decoration overpowering the main decision or CTA.
- Wrong copy: vague headings, soft CTA text, jargon, duplicate labels, and error messages that blame the user without telling them what to do.
- Wrong density: either bloated emptiness that forces scrolling or cramped noise that kills scanning.
- Wrong responsiveness: hierarchy collapses on mobile, actions drop below the fold, panels become unusable, tables overflow, or tap targets become hostile.
- Wrong trust signals: destructive actions unclear, status invisible, saves ambiguous, permissions surprising, or system feedback delayed.

## Structural Reframes

Actively test whether the interface should be reorganized instead of merely polished:
- Make it a **separate page** when the task needs focus, depth, comparison, shareable URL state, or repeated return visits.
- Make it a **right-side inspector/panel** when users must keep the main object, canvas, or list visible while editing details.
- Make it a **wizard/step flow** when inputs depend on previous choices or users need reassurance through a guided sequence.
- Make it **inline** when the action is small, local, and benefits from immediate context.
- Make it a **command palette / power menu** when experts need fast access to many actions without cluttering the default UI.
- Make it a **radial menu** only when actions are few, frequent, spatially memorable, and pointer-driven; never as novelty or primary discovery.
- Split one screen into **two roles** when browsing and editing fight each other.
- Merge screens when users bounce back and forth only to preserve artificial boundaries.

## Output Contract

Return a numbered list ordered from most important to least important.

- Keep it concise: usually 5-10 items.
- Each item should name the area, state the problem, and propose the improvement in 1-2 sentences.
- Prefer findings that change structure, flow, comprehension, or action clarity before findings about aesthetics.
- Mention concrete rewrites when warranted: move the panel, split the page, kill the modal, simplify the form, rewrite the heading, promote the CTA, replace the pattern.
- Avoid generic filler like "improve spacing" unless you can say what the spacing problem is doing to comprehension or action.
- Do not lead with compliments, methodology, or long summaries.

## Relationships

- Use `frontend-design` after this audit when the user wants the redesigned UI implemented.
- Use `updesign` when the user wants a durable design-system artifact instead of a critique.
- Read `references/principles.md` only when you need more depth on the underlying design lens.
