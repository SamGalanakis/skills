---
name: uparchitecture
description: Create or update docs/architecture.html for the current repo. Generates a beautiful, self-contained HTML page documenting the project's technical architecture with Mermaid.js diagrams. Creates it if missing, updates it to reflect current state if it exists.
---

# Uparchitecture

Upsert `docs/architecture.html`. Create if missing, update to reflect current codebase if it exists.

## Sections (each gets its own tab)

- **Overview** — what the project is, KPIs (language, LOC, key deps, module count)
- **Modules** — each major module with purpose, key files, responsibilities
- **Data Flow** — how data moves through the system (Mermaid diagram)
- **Execution** — how the system runs, processes requests, handles events
- **Abstractions** — important traits, interfaces, types, patterns
- **Dependencies** — external services, libraries, integrations (Mermaid diagram where useful)
- **Files** — important paths and what lives where

## Tabbed Layout

**No long scrolling documents.** Use a sticky tab bar with vanilla JS show/hide. Re-render Mermaid on tab switch with `mermaid.run()`.

## Mermaid.js

Use diagrams wherever they clarify structure or flow. Good fits: `flowchart TD` for system overview, `flowchart LR` for data flow, `sequenceDiagram` for request lifecycle, `stateDiagram-v2` for state machines, `classDiagram` for type hierarchies.

```html
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
  mermaid.initialize({ startOnLoad: true, theme: 'base', themeVariables: { /* match page colors */ } });
</script>
```

Rules: always match `themeVariables` to page palette. One concept per diagram. Wrap in styled containers.

## Page Rules

Single self-contained HTML file. All CSS inline in `<style>`. No frameworks. Google Fonts and Mermaid CDN are fine.

**Design quality:**
- Study the project first — absorb the domain and vibe
- If `docs/design.html` exists, adopt its aesthetic exactly (fonts, colors, textures, layout)
- Otherwise, choose a bold direction and commit: brutalist, editorial, retro-terminal, industrial, etc.
- Distinctive fonts (never Inter/Roboto/Arial), real color system via CSS custom properties, texture and atmosphere (noise, gradients, grain)

**Never:** purple-on-white gradients, system fonts, cookie-cutter cards with soft shadows, Tailwind classes, emoji headers, default Mermaid colors.

## Workflow

**Creating:** Read codebase → check for `docs/design.html` and match its aesthetic → create `docs/` if needed → generate page.

**Updating:** Read existing file → check `docs/design.html` for aesthetic sync → read codebase for changes → preserve aesthetic → update content and diagrams → add/remove sections as needed.
