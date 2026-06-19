---
name: visual-explainer
description: >-
  Turn a topic, plan, codebase, architecture, or feature into a single
  self-contained HTML visual explainer — wireframes, diagrams, annotated code,
  file maps, and before/after panels in one offline file. Use when prose alone
  would be a wall of text and the reader would understand it faster as a
  scannable visual document.
---

# Visual Explainer

Turn something hard to grasp from prose into a **single self-contained `.html`
file** that explains it visually: inline architecture/data-flow diagrams, UI
wireframes, annotated code, file maps, before/after comparisons, callouts, and
clean structured prose. The output is one file a person opens in a browser — no
server, no account, no network, no sharing service. It works offline and can be
checked into a repo.

Use it to explain a plan before implementation, walk someone through a codebase
or architecture, document how a feature works, present a before/after change, or
make an abstract concept concrete.

## When To Use

Create a visual explainer whenever the material would land better as a scannable
visual artifact than a chat paragraph: a UI surface with states, a multi-file or
architectural change, a data/control flow, a before/after comparison, a
component/API/data-shape decision, or any concept where a diagram, mockup, or
file map does the explaining faster than words.

Skip it for trivial, unambiguous things — a one-line answer, a typo, a single
well-specified function — and just say it in chat. Never pad an explainer with
filler, and never ship a one-section document that should have been a sentence.

## Output Contract

- **One file.** Everything — CSS, content, the theme toggle — lives in a single
  `.html` file. No external CSS/JS dependencies, no CDN links that break offline.
- **Self-styled.** The look is owned by the bundled design system in
  `references/design-system.md`. Paste its scaffold, then fill `<main>`. Do not
  invent a new stylesheet per explainer and do not pull in a UI framework.
- **No hosting, no accounts, no sharing.** This skill never publishes, uploads,
  or registers anything. If the user wants to share the result, they send the
  file or check it into their repo.
- **Name it sensibly.** Default to `<topic>-explainer.html` in the working
  directory, or wherever the user asks (e.g. `docs/`). State the path when done.

## Discipline

- **Research before you draft.** Read the real files, symbols, schema, and
  patterns first; name actual files and data shapes instead of inventing them.
  Lead with what already exists, then the genuinely new delta. Delegate wide
  exploration to a sub-agent when the surface is large.
- **Gate thoughtfully.** A visual explainer is a richer surface, not a reward for
  big projects. Use it when seeing the thing helps; skip it for the trivially
  describable.
- **Keep examples at the right altitude.** When the topic is a broad framework or
  operating model, do not collapse it into the first concrete example. Separate
  the core abstraction from motivating examples and adapters; label examples as
  examples.
- **Make the first read concrete.** If the concept is abstract, lead near the top
  with one concrete example — a real screen mockup or a worked scenario — before
  taxonomies, mode tables, or architecture.
- **Stand alone.** The file must make sense to a reader who never saw the chat.
  No "as discussed above", "this revision", or other conversation references.
- **Clarify vs. assume.** Explore and present; do not ask how to build the
  explainer. Ask a clarifying question only when an ambiguity would change the
  content and you cannot resolve it from the code — batch 2–4 high-leverage
  questions. Otherwise state the assumption and proceed.

## Choosing the visual surface

Do not add visual chrome by default. Match the surface to the material:

- **No visual / document-only** for backend, data, copy, or purely conceptual
  topics. Write strong prose with local inline diagrams only where relationships
  are genuinely spatial — usually one diagram per point. Prefer grouped regions,
  layers, matrices, or before/after panels over a single-axis chain.
- **Wireframe(s)** for product UI: a screen, a state, a before/after, a small
  popover. Use `references/wireframe.md`. Put multiple states in a `.columns`
  before/after rather than one cramped frame.
- **Diagram(s)** for architecture, dependency, data-flow, or state relationships.
  Use `references/diagrams.md`. Keep diagrams local to the point they support.
- **Mix** when the topic has both a UI story and an architecture story — but each
  visual must earn its place, and visuals never duplicate the prose.

## Build steps

1. **Understand the topic.** Inspect the codebase / read the source material;
   gather what you need; resolve or batch clarifying questions.
2. **Pick the surface(s)** per the section above.
3. **Scaffold the file.** Copy the scaffold from `references/design-system.md`,
   set the title and header, and plan the `<main>` sections.
4. **Author the content** using the building blocks in `references/content.md`
   (prose, annotated code, file maps, comparisons, callouts), the mockups in
   `references/wireframe.md`, and the diagrams in `references/diagrams.md`. Ground
   everything in real files and real names.
5. **Open it and check.** Open the `.html` in a browser, toggle light and dark,
   and fix overlap, clipped content, poor contrast, and unreadable diagrams
   before calling it done. Then tell the user the file path.

## References — read before authoring

- `references/design-system.md` — the self-contained HTML scaffold + CSS (theme
  tokens, surfaces, diagram primitives). **Read first**; the other references
  assume its classes and tokens. Paste the scaffold into every explainer.
- `references/wireframe.md` — UI mockup quality bar. Read before authoring any
  wireframe / `.surface` screen.
- `references/diagrams.md` — architecture/data-flow/state diagrams in HTML+SVG
  and spatial layout. Read before authoring any diagram.
- `references/content.md` — prose and structured-block quality bar, the HTML
  building blocks, and the good/bad exemplars. Read before authoring the body.
