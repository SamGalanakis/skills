# Bundled design system — the look is yours, ship it in the file

There is no external renderer. A visual explainer is **one self-contained
`.html` file** that a person opens in a browser with no server, no account, and
no network. That means *this skill* owns the look: you paste the scaffold below
into every explainer, then fill the `<main>` with content. The CSS defines the
theme tokens, the typography, the surfaces, and the diagram primitives that the
rest of the references assume. Do not hand-roll a new stylesheet per explainer
and do not pull a CSS framework off a CDN — copy this scaffold so every explainer
looks consistent and works offline.

**Token contract.** Reference these custom properties for every color, border,
and radius — never hard-code a hex/rgb/hsl value in content, and never set
`font-family` on content (the scaffold owns the font). The tokens flip
automatically between light and dark, so reading them is what keeps the explainer
correct in both themes:

`--wf-ink` (text) · `--wf-muted` (secondary text) · `--wf-line`
(borders/dividers) · `--wf-paper` (page background) · `--wf-card` (container
surface) · `--wf-accent` / `--wf-accent-fg` / `--wf-accent-soft` (the one brand
action color) · `--wf-warn` · `--wf-ok` · `--wf-radius`.

**Helper classes** (same vocabulary the wireframe and diagram references use):

- `.wf-card` / `.wf-box` — a bordered, padded container (panel, list item).
- `.wf-pill` / `.wf-chip` — a rounded tag/filter; add `.accent` for the filled variant.
- `.wf-muted` — secondary text (or use `<small>`).
- `button.primary` or any `[data-primary]` — the accent-filled primary action.
- `.surface` + `.surface-{browser,desktop,mobile,popover,panel}` — a wireframe frame (see `wireframe.md`).
- `.diagram-panel` / `.diagram-card` / `.diagram-node` / `.diagram-box` / `.diagram-pill` / `.diagram-muted` — diagram primitives (see `diagrams.md`).
- `.callout` + `.tone-{decision,warn,ok,info}` — a labeled aside.
- `.columns` — an auto-fitting side-by-side grid (before/after, current/target).
- `.filetree` — a monospace file map. `.annotated` — code with margin notes.

**No fake depth.** No `box-shadow`, `filter: drop-shadow`, or other depth tricks
on cards, frames, or diagram nodes. Surfaces read flat and bordered; use spacing,
borders, and labels for separation.

## The scaffold — paste this, then fill `<main>`

Copy verbatim. Replace the `<title>`, the header text, and the `<main>` body.
The theme toggle and the "respect OS preference" default are already wired.

```html
<!doctype html>
<html lang="en" data-theme="auto">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>TITLE — Visual Explainer</title>
    <style>
      :root {
        --wf-ink: #1c2024;
        --wf-muted: #6b7280;
        --wf-line: #d7dbe0;
        --wf-paper: #f6f7f9;
        --wf-card: #ffffff;
        --wf-accent: #3b5bdb;
        --wf-accent-fg: #ffffff;
        --wf-accent-soft: #e7ecfb;
        --wf-warn: #c2410c;
        --wf-ok: #15803d;
        --wf-radius: 10px;
        --wf-maxw: 940px;
        --wf-font: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto,
          Helvetica, Arial, sans-serif;
        --wf-mono: ui-monospace, "SF Mono", "JetBrains Mono", "Fira Code",
          Menlo, Consolas, monospace;
        color-scheme: light;
      }
      [data-theme="dark"] {
        --wf-ink: #e7e9ec;
        --wf-muted: #9aa3ad;
        --wf-line: #2b3138;
        --wf-paper: #14171a;
        --wf-card: #1c2024;
        --wf-accent: #7c93f0;
        --wf-accent-fg: #14171a;
        --wf-accent-soft: #232a3d;
        --wf-warn: #f0894e;
        --wf-ok: #5fbf7f;
        color-scheme: dark;
      }
      @media (prefers-color-scheme: dark) {
        [data-theme="auto"] {
          --wf-ink: #e7e9ec;
          --wf-muted: #9aa3ad;
          --wf-line: #2b3138;
          --wf-paper: #14171a;
          --wf-card: #1c2024;
          --wf-accent: #7c93f0;
          --wf-accent-fg: #14171a;
          --wf-accent-soft: #232a3d;
          --wf-warn: #f0894e;
          --wf-ok: #5fbf7f;
          color-scheme: dark;
        }
      }
      * { box-sizing: border-box; }
      html { scroll-behavior: smooth; }
      body {
        margin: 0;
        font-family: var(--wf-font);
        color: var(--wf-ink);
        background: var(--wf-paper);
        line-height: 1.6;
        -webkit-font-smoothing: antialiased;
      }
      .wrap { max-width: var(--wf-maxw); margin: 0 auto; padding: 32px 24px 96px; }
      header.doc {
        display: flex; align-items: flex-start; justify-content: space-between;
        gap: 16px; margin-bottom: 28px; padding-bottom: 20px;
        border-bottom: 1.4px solid var(--wf-line);
      }
      header.doc h1 { font-size: 1.8rem; line-height: 1.2; margin: 0 0 6px; }
      header.doc .sub { color: var(--wf-muted); margin: 0; }
      main > section { margin: 0 0 40px; }
      h2 { font-size: 1.3rem; margin: 0 0 12px; }
      h3 { font-size: 1.05rem; margin: 24px 0 8px; }
      h4 { font-size: 0.95rem; margin: 0 0 8px; }
      p, ul, ol { margin: 0 0 14px; }
      ul, ol { padding-left: 22px; }
      li { margin: 4px 0; }
      a { color: var(--wf-accent); text-decoration: none; }
      a:hover { text-decoration: underline; }
      hr { border: none; border-top: 1.4px solid var(--wf-line); margin: 24px 0; }
      code {
        font-family: var(--wf-mono); font-size: 0.86em;
        background: var(--wf-accent-soft); color: var(--wf-ink);
        padding: 1px 5px; border-radius: 5px;
      }
      pre {
        font-family: var(--wf-mono); font-size: 0.82rem; line-height: 1.55;
        background: var(--wf-card); border: 1.4px solid var(--wf-line);
        border-radius: var(--wf-radius); padding: 14px 16px; overflow-x: auto;
        margin: 0 0 14px;
      }
      pre code { background: none; padding: 0; font-size: inherit; }

      .wf-card, .wf-box {
        background: var(--wf-card); border: 1.4px solid var(--wf-line);
        border-radius: var(--wf-radius); padding: 16px;
      }
      .wf-muted { color: var(--wf-muted); }
      .wf-pill, .wf-chip {
        display: inline-flex; align-items: center; gap: 6px;
        border: 1.4px solid var(--wf-line); border-radius: 999px;
        padding: 2px 10px; font-size: 0.8rem; color: var(--wf-ink);
        white-space: nowrap;
      }
      .wf-pill.accent, .wf-chip.accent {
        background: var(--wf-accent); border-color: var(--wf-accent);
        color: var(--wf-accent-fg);
      }
      button, .btn {
        font: inherit; cursor: pointer; border-radius: 8px;
        border: 1.4px solid var(--wf-line); background: var(--wf-card);
        color: var(--wf-ink); padding: 7px 14px;
      }
      button.primary, [data-primary] {
        background: var(--wf-accent); border-color: var(--wf-accent);
        color: var(--wf-accent-fg);
      }
      input, select, textarea {
        font: inherit; color: var(--wf-ink); background: var(--wf-paper);
        border: 1.4px solid var(--wf-line); border-radius: 8px; padding: 7px 10px;
        width: 100%;
      }
      label { display: block; font-size: 0.9rem; }

      /* Callouts */
      .callout {
        border: 1.4px solid var(--wf-line); border-left-width: 4px;
        border-radius: var(--wf-radius); background: var(--wf-card);
        padding: 12px 16px; margin: 0 0 16px;
      }
      .callout > .label {
        font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.06em;
        font-weight: 700; color: var(--wf-muted); margin-bottom: 4px;
      }
      .callout.tone-decision { border-left-color: var(--wf-accent); }
      .callout.tone-decision > .label { color: var(--wf-accent); }
      .callout.tone-warn { border-left-color: var(--wf-warn); }
      .callout.tone-warn > .label { color: var(--wf-warn); }
      .callout.tone-ok { border-left-color: var(--wf-ok); }
      .callout.tone-ok > .label { color: var(--wf-ok); }
      .callout.tone-info { border-left-color: var(--wf-muted); }

      /* Side-by-side columns */
      .columns {
        display: grid; gap: 16px;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      }
      .columns > .col > h4 { color: var(--wf-muted); margin: 0 0 8px; }

      /* Tables */
      table { width: 100%; border-collapse: collapse; margin: 0 0 16px; font-size: 0.9rem; }
      th, td { text-align: left; padding: 8px 12px; border-bottom: 1.4px solid var(--wf-line); }
      th { color: var(--wf-muted); font-weight: 600; }

      /* File tree */
      .filetree {
        font-family: var(--wf-mono); font-size: 0.84rem; line-height: 1.7;
        background: var(--wf-card); border: 1.4px solid var(--wf-line);
        border-radius: var(--wf-radius); padding: 14px 16px; white-space: pre;
        overflow-x: auto;
      }
      .filetree .new { color: var(--wf-ok); }
      .filetree .note { color: var(--wf-muted); }

      /* Annotated code: a code column with margin notes */
      .annotated { display: grid; grid-template-columns: 1fr; gap: 8px; }
      @media (min-width: 720px) {
        .annotated.has-notes { grid-template-columns: 1fr 230px; align-items: start; }
      }
      .annotated .notes { display: flex; flex-direction: column; gap: 10px; }
      .annotated .notes .n {
        font-size: 0.82rem; border-left: 3px solid var(--wf-accent);
        padding-left: 10px; color: var(--wf-muted);
      }
      .annotated .notes .n b { color: var(--wf-ink); }

      /* Wireframe surfaces */
      .surface {
        background: var(--wf-card); border: 1.6px solid var(--wf-line);
        border-radius: var(--wf-radius); overflow: hidden; position: relative;
      }
      .surface > .chrome {
        display: flex; align-items: center; gap: 8px;
        padding: 8px 12px; border-bottom: 1.4px solid var(--wf-line);
        background: var(--wf-paper); font-size: 0.8rem; color: var(--wf-muted);
      }
      .surface > .chrome .dot {
        width: 10px; height: 10px; border-radius: 999px;
        border: 1.4px solid var(--wf-line);
      }
      .surface > .body { height: 100%; }
      .surface-browser { width: 100%; max-width: 720px; }
      .surface-browser > .body { min-height: 340px; }
      .surface-desktop { width: 100%; }
      .surface-desktop > .body { min-height: 420px; }
      .surface-mobile { width: 300px; }
      .surface-mobile > .body { min-height: 560px; }
      .surface-popover { width: 280px; }
      .surface-panel { width: 340px; }
      .surface-panel > .body { min-height: 420px; }

      /* Diagram primitives */
      .diagram-panel {
        background: var(--wf-card); border: 1.6px solid var(--wf-line);
        border-radius: var(--wf-radius); padding: 18px;
      }
      .diagram-card, .diagram-node, .diagram-box {
        background: var(--wf-paper); border: 1.5px solid var(--wf-line);
        border-radius: 8px; padding: 10px 14px; text-align: center;
      }
      .diagram-node { font-weight: 600; }
      .diagram-pill {
        display: inline-block; border: 1.4px solid var(--wf-line);
        border-radius: 999px; padding: 2px 10px; font-size: 0.8rem;
        background: var(--wf-accent-soft);
      }
      .diagram-muted { color: var(--wf-muted); font-size: 0.85rem; }
      .diagram-panel svg { display: block; max-width: 100%; height: auto; }
      [data-rough] { /* hook for rough-edge styling if ever added; flat by default */ }

      /* In-page nav (optional, for long explainers) */
      nav.toc {
        position: sticky; top: 0; background: var(--wf-paper);
        padding: 10px 0; margin-bottom: 24px; z-index: 5;
        border-bottom: 1.4px solid var(--wf-line);
        display: flex; gap: 14px; flex-wrap: wrap; font-size: 0.88rem;
      }

      .theme-toggle {
        border: 1.4px solid var(--wf-line); background: var(--wf-card);
        color: var(--wf-muted); border-radius: 8px; padding: 6px 12px;
        cursor: pointer; font: inherit; font-size: 0.85rem; flex: none;
      }
      @media print {
        .theme-toggle, nav.toc { display: none; }
        body { background: #fff; }
        .wrap { max-width: none; }
      }
    </style>
  </head>
  <body>
    <div class="wrap">
      <header class="doc">
        <div>
          <h1>TITLE</h1>
          <p class="sub">One sentence on what this explains and who it is for.</p>
        </div>
        <button class="theme-toggle" id="themeToggle">◐ Theme</button>
      </header>

      <main>
        <!-- Content sections go here. See content.md, wireframe.md, diagrams.md. -->
      </main>
    </div>

    <script>
      // Theme: auto (OS) → light → dark → auto. No storage dependency required.
      (function () {
        var order = ["auto", "light", "dark"];
        var root = document.documentElement;
        var btn = document.getElementById("themeToggle");
        var saved = null;
        try { saved = localStorage.getItem("ve-theme"); } catch (e) {}
        if (saved) root.setAttribute("data-theme", saved);
        function label() {
          btn.textContent = "◐ " + root.getAttribute("data-theme");
        }
        label();
        btn.addEventListener("click", function () {
          var cur = root.getAttribute("data-theme") || "auto";
          var next = order[(order.indexOf(cur) + 1) % order.length];
          root.setAttribute("data-theme", next);
          try { localStorage.setItem("ve-theme", next); } catch (e) {}
          label();
        });
      })();
    </script>
  </body>
</html>
```

## Optional libraries — local-first, never required

Default to hand-authored HTML/SVG with the primitives above; a bespoke diagram
reads better and always works offline. If a diagram is genuinely easier as
Mermaid (large dependency graphs, sequence diagrams, gantt), you may add it, but
keep the file self-contained: vendor the library inline rather than hot-linking a
CDN that breaks offline. Note in the explainer that a library is embedded. Never
pull in a UI/CSS framework — the scaffold is the design system.
