# Content quality & building blocks

This is the quality bar for the prose and structured blocks of the explainer —
how it reads, which HTML patterns to use, and the good/bad bar. Read it before
authoring the body; do not write from memory.

**An explainer is a serious technical document, not marketing.** Write it the way
a strong engineer would explain the thing to a peer: outcome-first, prose-first,
self-contained, and specific. Lead with what the reader will understand by the
end. Name real files, symbols, functions, and data shapes instead of inventing
them. Replace vague prose with specifics. No hero art, gradients, logos, slogans,
value props, giant landing-page headings, or marketing cards unless the user
explicitly asks.

**Every explainer must stand alone.** A reader who opens the HTML file with no
chat history should understand it. Do not write phrases like "as discussed
above", "this revision", "unlike the prior version", or other references to the
conversation that produced it. State the positive model directly; avoid negative
framing that only makes sense against absent context ("not the old mode", "not
just X") unless the contrast is defined in the explainer itself.

**Make abstract topics instantly legible.** If the idea is broad or strategic,
put one concrete example near the top — a real screen mockup, a worked scenario,
or a single end-to-end walkthrough — before dense architecture, tables, or
taxonomies. Then put mechanics and detail in later sections.

**Preserve the right level of abstraction.** A motivating example is not the
whole architecture. When the topic is a broader framework or reusable primitive,
separate the reusable core from specific apps, providers, or examples. Use the
concrete example to make it legible, then make clear which parts are core and
which are illustrative.

**Visuals and prose never duplicate each other.** A wireframe shows the UI; the
prose carries the technical depth the visual cannot — file/symbol maps, data
contracts, code, phases, risks. A diagram shows the spatial relationship; the
prose states the why. Repeat a visual only for a genuinely new detail or
comparison. Skip visuals entirely for non-visual topics and write a clean,
well-structured document.

## Building blocks (HTML patterns)

Use the right block and make it carry substance. All classes come from
`design-system.md`.

- **Prose** — normal `<h2>`/`<h3>`/`<p>`/`<ul>` with real `<strong>`,
  `<em>`, `<code>`, and links. This is the backbone; most of the explainer is
  prose.
- **Annotated code** — when a load-bearing file is worth showing, prefer the
  annotated walkthrough over a bare code block: carry the real code AND anchor
  short margin notes to the lines that matter. Use the `.annotated.has-notes`
  grid: a `<pre><code>` column plus a `.notes` column of `.n` notes, each naming
  what to look at and why. Keep a few high-signal notes, not one per line.
  Highlight only files worth reading — never an exhaustive list of every touched
  file.

  ```html
  <div class="annotated has-notes">
    <pre><code>export async function syncPlan(id) {
    const plan = await db.plans.get(id);
    if (!plan) throw new NotFound(id);
    return push(plan);   // fire-and-forget today
  }</code></pre>
    <div class="notes">
      <div class="n"><b>Line 3</b> — the only NotFound path; callers rely on it.</div>
      <div class="n"><b>Line 4</b> — push is not awaited; this is the bug.</div>
    </div>
  </div>
  ```

- **File map** — use a `.filetree` block for "what lives where" and what is new.
  Mark added paths with `<span class="new">` and trailing notes with
  `<span class="note">`.
- **Comparison** — a `.columns` grid for side-by-side before/after or
  current/target, each `.col` with an `<h4>` label and real nested content.
- **Diagram** — a `.diagram-panel` for two-dimensional relationships only (see
  `diagrams.md`).
- **Callout** — a `.callout` with `.tone-decision` for a settled decision (state
  the choice and the rationale), `.tone-warn` for a risk or gotcha, `.tone-ok`
  for a confirmed-good note, `.tone-info` for an aside. Give each a `.label`.
- **Table / list** — a `<table>` or `<ul>` for scannable structure.
- **Open questions** (when the explainer is also a proposal awaiting input) — a
  single section at the bottom. List each genuinely-open decision with the
  options and a recommended default. This is the ONLY place open questions are
  enumerated; do not scatter a second questions list earlier.

## Good vs. bad

**GOOD.** A UI explainer: one `.surface-desktop` mockup of the real screen built
from helper classes and tokens, with a short note beside it pointing only at the
control that changed. Below it, prose that carries the depth the mockup cannot —
the load-bearing file shown as annotated code, a `.callout tone-decision` stating
the chosen approach with a `.columns` block weighing the two real options behind
it — none of it repeating the mockup.

**GOOD.** A broad architecture explainer opens with a plain summary and one
concrete example state before the abstraction. A `.diagram-panel` shows the
mechanics as layered bands, not a left-to-right chain. The prose separates the
reusable core from app/provider adapters, covers contracts and data shape, and
ends with a clean verification or "how to confirm" section. A reader who was not
in the chat gets the idea from the top example before the technical depth.

**GOOD.** A codebase walkthrough: no UI mockup. The document opens with context,
then repeats a section rhythm — a heading, a `.filetree` or monospace path
evidence, one inline before/after or layered diagram local to that point, and
terse Problem/Why prose using the codebase's own vocabulary. Each diagram sits
next to the claim it supports.

**BAD.** Hard-coded hex colors or a `font-family` on content; gray placeholder
bars faking text on a non-skeleton frame; a forced desktop + mobile pair for a
popover; floating bordered annotation cards hugging the frames; a multi-state UI
shown as one cramped frame instead of a `.columns` before/after; a diagram that
is a wall of labeled boxes with overlapping text and no real spatial meaning; a
marketing-style document with a hero heading and value props that just restates
what a mockup already shows; an explainer that describes itself as a revision of
a prior conversation instead of standing alone. Never produce this.

## Before handoff, open it and check

Open the generated `.html` in a browser. Toggle light and dark. Fix overlap,
excessive whitespace, clipped fragments, misleading inactive controls, poor
contrast, and unreadable diagrams before calling it done.
