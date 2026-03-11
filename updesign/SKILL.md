---
name: updesign
description: Create or update docs/design.html for the current repo. Generates a beautiful, self-contained HTML page documenting the project's design system and visual identity. Creates it if missing, updates it to reflect current state if it exists.
---

# Updesign

Upsert `docs/design.html`. Create if missing, update to reflect current codebase if it exists.

## Sections (each gets its own tab)

- **Identity** — name treatment, logo concepts, brand personality
- **Color** — core palette, extended shades, semantic mappings, rendered swatches
- **Typography** — font choices, scale, weights, pairings, rendered specimens
- **Elements** — component patterns, borders, cards, indicators, spacing
- **Texture** — background treatments, overlays, grain, gradients
- **Iconography** — recurring motifs, shapes, visual metaphors
- **Principles** — design philosophy and guiding rules

For projects with no UI (pure libraries), cover API design patterns, code style conventions, and documentation aesthetics instead.

## Tabbed Layout

**No long scrolling documents.** Use a sticky tab bar with vanilla JS show/hide. Re-render Mermaid on tab switch with `mermaid.run()`.

## Mermaid.js

Use diagrams where they clarify design system relationships: color token hierarchy (`flowchart TD`), typography scale, component anatomy, design token cascade, state/variant matrices.

```html
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
  mermaid.initialize({ startOnLoad: true, theme: 'base', themeVariables: { /* match page colors */ } });
</script>
```

Rules: always match `themeVariables` to page palette. One concept per diagram. Wrap in styled containers.

## Page Rules

Single self-contained HTML file. All CSS inline in `<style>`. No frameworks. Google Fonts and Mermaid CDN are fine.

The design doc itself **is** the first artifact of the design system — it must embody what it documents.

**Design quality:**
- Study the project first — absorb the domain and vibe
- Choose a bold direction and commit: brutalist, editorial, retro-terminal, industrial, etc.
- Distinctive fonts (never Inter/Roboto/Arial), real color system via CSS custom properties, texture and atmosphere
- **Show, don't tell** — render swatches, type specimens, component examples. Never just list hex codes.

**Never:** purple-on-white gradients, system fonts, cookie-cutter cards with soft shadows, Tailwind classes, emoji headers, colors without swatches, typography without specimens, default Mermaid colors.

## Workflow

**Creating:** Read codebase → look for existing design cues (CSS colors, fonts, UI patterns) → create `docs/` if needed → generate page.

**Updating:** Read existing file → read codebase for changes → preserve aesthetic → update content and diagrams → add/remove sections as needed.
