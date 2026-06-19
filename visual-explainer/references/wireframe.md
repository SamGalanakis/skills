# UI mockup (wireframe) quality bar

A wireframe is an HTML mockup of a screen, dropped straight into the explainer's
`<main>` inside a `.surface` frame. Read this in full before authoring any
mockup; do not author from memory.

**You write real product content; the design system styles it.** Wrap the screen
in a `.surface .surface-{preset}` frame from `design-system.md`, put the screen
HTML inside a `.body` element, and write plain semantic HTML for the content. The
bundled CSS owns the frame footprint, the theme, and the component look — you
never write `<style>` blocks, `font-family`, or fixed pixel widths/heights on the
screen content.

**Skeleton of a mockup:**

```html
<div class="surface surface-browser">
  <div class="chrome"><span class="dot"></span><span class="dot"></span><span class="dot"></span>&nbsp; app.example.com/sign-in</div>
  <div class="body">
    <div style="display:flex;flex-direction:column;gap:10px;padding:16px;height:100%">
      <h1>Sign in</h1>
      <p class="wf-muted">Use your work email to continue.</p>
      <div class="wf-card" style="display:flex;flex-direction:column;gap:10px">
        <label>Email<input value="jane@acme.co" /></label>
        <label>Password<input value="••••••••" /></label>
        <label style="display:flex;align-items:center;gap:8px"><input type="checkbox" checked /> Remember me</label>
        <button class="primary">Sign in</button>
      </div>
      <a href="#">Forgot password?</a>
    </div>
  </div>
</div>
```

**Write PLAIN semantic HTML and let the design system style it.** Bare elements
(`h1`/`h2`/`h3`, `p`, `button`, `input`, `<input type="checkbox">`, `a`, `hr`)
are auto-themed — no classes needed. Helper classes carry the rest: `.wf-card` /
`.wf-box` for a bordered container, `.wf-pill` / `.wf-chip` for a tag or filter
(add `.accent` for the filled variant), `.wf-muted` (or `<small>`) for secondary
text, and `button.primary` / `[data-primary]` for the accent-filled primary
action.

**Use the `--wf-*` tokens for any custom color, never hex.** The tokens flip on
light/dark, so reading them is what keeps a mockup correct in both themes. For
any inline border, background, or text color, reference a token:
`style="border:1.4px solid var(--wf-line)"`. Never hard-code a hex/rgb/hsl color
and never set `font-family` — the scaffold owns the font.

**No decorative shadows around mockups.** No `box-shadow`, `filter:
drop-shadow(...)`, or other fake depth on a frame, `.wf-card` / `.wf-box`, or any
mockup container. Mockups read as flat, bordered surfaces; use spacing, borders,
labels, and annotations for separation. Only show a shadow when the real product
UI already has one and it is essential to the point being made.

**Icons.** Use a short inline SVG, or a single emoji/glyph as a placeholder, for
icon-only buttons and leading icons. Do NOT write visible words like "email",
"lock", "search", "chevron", or "more" where the product UI would show an icon —
use text only when it is a real label a user would read.

**Lay out with inline `style` flex/grid.** You write the real layout —
`display:flex; flex-direction:column; gap:10px; padding:16px` and so on. Compose
the actual product: reproduce the current screen, then show the modification.
Real labels, real counts, real dates, real button text grounded in the screen
you read — never lorem or gray bars.

**Surface presets — match the real footprint, never default to desktop+mobile.**
Pick the `.surface-*` class that matches what the user will actually see:

- `surface-browser`: a web page that needs browser chrome (use the `.chrome` bar).
- `surface-desktop`: a full desktop app page or app shell.
- `surface-mobile`: a phone screen, only when the work is genuinely mobile.
- `surface-popover`: a small floating menu, dropdown, or inline popover.
- `surface-panel`: a side panel, inspector, or sidebar widget.

A sidebar popover renders as a small surface, not a desktop page plus a phone
frame. Do not emit `desktop` + `mobile` variants unless responsive behavior
actually changes the layout.

**Model the actual component shell for small surfaces.** A rendered UI change
belongs in a wireframe; reserve diagrams (see `diagrams.md`) for architecture,
dependency, state, or data-flow relationships. Popovers, dropdown menus, command
palettes, and context menus use `surface-popover` unless the surrounding page
placement is the point. Dialogs, sheets, inspectors, sidebars, and long property
panels use the matching `surface-panel` / `surface-desktop`. Show the real
chrome: trigger or anchor when it matters, title/header row, top-right actions,
separators, fields, options, selected states, body content, and footer actions
visible in the workflow.

**Modify, don't redesign.** When the topic changes an existing screen, reproduce
the current screen's real layout and footprint FIRST, then change only the delta
and call it out with a single annotation. Do not restack the page into a new
layout. For net-new surfaces, compose from the real app shell. Inspect the
actual app components before drawing an existing product: sidebar density,
toolbar actions, overflow menus, property panels, and framework chrome should
match the product unless intentionally changed.

**Keep product screens pure.** A product wireframe shows the app state a user
would actually see. Do not embed file contracts, architecture arrows, repo pills,
mode explanations, or implementation callouts inside the screen just to explain
something. Put those in a `.callout`, a separate diagram, or the surrounding
prose.

**Zoom in on sub-surfaces, don't redraw the page.** For a small sub-surface (a
popover, menu, dialog, toast), show the full screen once, then add a small
separate `.surface-popover` (or matching preset) whose body contains ONLY that
sub-surface — do not re-draw the whole page around it, and never widen a popover
to page width.

**Loading / skeleton states.** Fill the body with neutral, textless placeholder
geometry — `<div>`s with `background:var(--wf-line)` and explicit
heights/widths, no labels or copy. Keep it inside a normal `.surface`; do not
escape into a custom stylesheet to fake a loader.

**Wrap content with real padding.** Always wrap screen content in a root
container with at least 14–16px inner padding, `box-sizing: border-box`,
`height: 100%`, and `gap` between rows so the first row never sits flush against
the frame border. Every container, field, button, and menu item needs enough
padding and line-height to read cleanly.

**Lay out children safely.** Use flex/grid with `gap`, `min-width: 0`, and
sensible overflow. Avoid negative margins, absolute positioning, or fixed child
widths that can collide between light/dark or at different zoom levels.

**Do not wrap intentionally single-line labels.** For toolbars, tab rails,
breadcrumbs, chip/filter rows, branch and file names, and code filenames — any
deliberately single-line row — put `white-space: nowrap` on the row (and
`overflow: hidden; text-overflow: ellipsis` on labels that can grow) so the
mockup demonstrates the real layout behavior instead of ugly stacked text.

**Fill the frame; keep labels short.** Each surface is a fixed-footprint frame —
compose enough realistic HTML to fill it top to bottom with even vertical rhythm;
never leave a large empty band. On desktop/app-shell sidebars let the nav stack
`flex:1` to fill, and add any persistent bottom action/status after it. On mobile
especially, flow real rows down the whole screen (status bar, header, then
content) rather than a header floating above a gap. Keep every label short enough
to sit on one line within its column.

**Persistent chrome bars span the full frame width.** Top bars, app headers,
toolbars, and bottom tab/nav bars are full-width chrome. Lay each one out as a
single flex row that fills the frame
(`style="display:flex;align-items:center;width:100%"`) and push trailing actions
to the right with a flex spacer (`<div style="flex:1"></div>`) — never center a
bar inside a narrow block, and never let it collapse to the width of its
contents. In a Before/After pair the bar stays full-width in BOTH states; the
spacer absorbs the difference.

**Pin bottom bars to the bottom of the frame.** For mobile tab bars and footers,
make the screen root a flex column at `height:100%`
(`style="display:flex;flex-direction:column;height:100%"`), give the scrolling
body `flex:1`, and place the bar as the LAST child (or set `margin-top:auto`) so
it sits flush at the bottom instead of floating with an empty band beneath it.

**Before / after must be comparable.** When showing a state change, preserve the
unchanged controls in both states so the reviewer sees exactly what moved or
appeared; do not show an added control as a generic box floating elsewhere. Place
the new affordance where the implementation puts it. Use the same frame size,
scale, padding, radius, and density on both sides unless the change itself alters
them.

**Name the states with a column header, never inside the frame.** Put the two
states in a `.columns` block and set each column's `<h4>` to `Before` and
`After`. Do NOT bake a `Before`/`After` pill, title, or heading into the screen
HTML — a label inside reads as part of the product UI and clutters the
comparison. The column header is the one and only place the state name belongs.

## Good example — a contacts list, `surface-browser`

A small, real screen composed from helper classes and tokens, layout in inline
flex, no fonts or hex colors:

```html
<div class="surface surface-browser">
  <div class="body">
    <div style="display:flex;flex-direction:column;gap:12px;padding:16px;height:100%">
      <div style="display:flex;align-items:center;justify-content:space-between">
        <h1>Contacts</h1>
        <button class="primary">New contact</button>
      </div>
      <div style="display:flex;gap:6px">
        <span class="wf-pill accent">All 128</span>
        <span class="wf-pill">Favorites</span>
        <span class="wf-pill">Archived</span>
      </div>
      <div class="wf-card" style="display:flex;flex-direction:column;gap:0;padding:0">
        <div style="display:flex;align-items:center;gap:10px;padding:10px 12px;border-bottom:1.4px solid var(--wf-line)">
          <div style="width:32px;height:32px;border-radius:999px;background:var(--wf-accent-soft)"></div>
          <div style="flex:1"><strong>Jane Cooper</strong><br /><small>jane@acme.co</small></div>
          <span class="wf-pill">Lead</span>
        </div>
        <div style="display:flex;align-items:center;gap:10px;padding:10px 12px">
          <div style="width:32px;height:32px;border-radius:999px;background:var(--wf-accent-soft)"></div>
          <div style="flex:1"><strong>Marcus Lee</strong><br /><small>marcus@globex.io</small></div>
          <span class="wf-pill">Customer</span>
        </div>
      </div>
    </div>
  </div>
</div>
```
