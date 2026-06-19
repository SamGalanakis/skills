# Diagrams & spatial layout

Diagrams explain two-dimensional relationships — architecture, dependencies,
data flow, state, ownership boundaries — that prose cannot show cleanly. Author
them as semantic HTML plus inline SVG inside a `.diagram-panel`, using the
diagram primitives from `design-system.md`. Read this in full before authoring a
diagram; do not author from memory.

**Use a diagram only when it clarifies something real.** A diagram earns its
place when relationships are genuinely spatial. If a point is a list, write a
list. One spatial diagram per recommendation or decision is usually right.

**Prefer two-dimensional layouts over single-axis chains.** Reach first for
paired before/after panels, layered diagrams, swimlanes, dependency maps,
matrices, quadrants, or grouped regions. Use a left-to-right line ONLY when the
relationship is truly a sequence. Do not default to "Box → Box → Box".

**Use the primitives, reference the tokens.** Build nodes from `.diagram-node` /
`.diagram-card` / `.diagram-box`, label regions with `.diagram-pill` and
`.diagram-muted`, and wrap everything in `.diagram-panel`. For connectors, draw
inline `<svg>` lines/arrows or use bordered CSS. Reference `--wf-ink`,
`--wf-muted`, `--wf-line`, `--wf-paper`, `--wf-card`, `--wf-accent`,
`--wf-accent-soft`, `--wf-warn`, `--wf-ok` for every color. Never set
`font-family` and never hard-code a hex/rgb/hsl color.

**Keep labels legible.** Keep labels short, give nodes generous width, and place
boundary/region labels in unused space rather than over nodes. Labels must not
overlap nodes, connectors, or each other. Inspect the rendered diagram at default
zoom in both themes before handoff and move anything that collides.

**No fake depth.** Flat, bordered nodes — no `box-shadow` or drop-shadow.

## Layout patterns

**Layered architecture** — stack labeled bands (e.g. UI / API / data), each band
a `.diagram-panel` row holding `.diagram-node`s, with a region label on the left:

```html
<div class="diagram-panel" style="display:flex;flex-direction:column;gap:12px">
  <div style="display:flex;align-items:center;gap:12px">
    <span class="diagram-pill">Client</span>
    <div class="diagram-node" style="flex:1">Web app (React)</div>
    <div class="diagram-node" style="flex:1">CLI</div>
  </div>
  <div style="display:flex;align-items:center;gap:12px">
    <span class="diagram-pill">API</span>
    <div class="diagram-node" style="flex:1">Auth service</div>
    <div class="diagram-node" style="flex:1">Sync service</div>
    <div class="diagram-node" style="flex:1">Export worker</div>
  </div>
  <div style="display:flex;align-items:center;gap:12px">
    <span class="diagram-pill">Data</span>
    <div class="diagram-node" style="flex:1">Postgres</div>
    <div class="diagram-node" style="flex:1">Object store</div>
  </div>
</div>
```

**Before / after panels** — two `.diagram-panel`s in a `.columns` grid with
`<h4>` headers, so the change is read side by side. Keep both panels at the same
density and node set so only the delta stands out.

**Grouped regions / boundaries** — wrap related nodes in a bordered region with
a corner `.diagram-pill` label to show an ownership or trust boundary; use
`--wf-warn` for a boundary that matters (a trust edge), `--wf-line` otherwise.

**Connectors with SVG** — for flows, overlay an inline `<svg>` with `<line>` /
`<path>` and an arrowhead `<marker>`, stroking with `var(--wf-line)` or
`var(--wf-accent)`. Connect only neighboring nodes; never draw a long connector
that skips across unrelated nodes. Reserve arrows for real sequences or one
specific pointed-at relationship — never fake "Step 1 → Step 2" lines between
independent things.

```html
<svg viewBox="0 0 400 60" style="width:100%">
  <defs>
    <marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L6,3 L0,6 Z" fill="var(--wf-accent)" />
    </marker>
  </defs>
  <line x1="20" y1="30" x2="380" y2="30" stroke="var(--wf-accent)"
        stroke-width="1.6" marker-end="url(#arrow)" />
</svg>
```

## Annotations (designer notes)

When a diagram or mockup needs explanation, write a short plain-text note beside
it — a `.diagram-muted` paragraph or a small `.callout`, not a bordered card
hugging the frame and not a box drawn around it. Anchor the note next to the
thing it explains. Use an arrow only to point at one specific control or
transition; a note that simply sits beside its subject needs no connector.

## When NOT to use a diagram

- A simple list, table, or `.columns` comparison conveys it better.
- The relationship is a single linear step ("do A, then B") — write prose.
- It would be a wall of labeled boxes with overlapping text and no real spatial
  meaning. That is worse than a clean paragraph.
- It is product UI — that is a wireframe (`wireframe.md`), not a diagram.
