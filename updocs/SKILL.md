---
name: updocs
description: Update documentation to reflect current code state by auditing docs vs code, fixing stale sections, and documenting new changes
---

# Updocs

Make all existing documentation reflect the current state of the code.

## What To Update

Find every documentation file in the repo — README, CLAUDE.md, AGENT.md, docs/, inline doc comments, API docs, etc. For each one, compare what the docs say against what the code actually does today.

Fix anything that is stale:

- **Wrong behavior descriptions** — if the docs say X but the code does Y, update the docs to say Y
- **Removed features** — if docs reference something that no longer exists, remove those references
- **Renamed things** — if files, functions, types, or modules were renamed, update all references
- **Changed APIs** — if function signatures, config options, CLI flags, or endpoints changed, update the docs
- **New undocumented features** — if there's significant new functionality with no docs, add documentation for it
- **Dead links** — if docs link to files or sections that no longer exist, fix or remove the links

## What NOT To Touch

Leave these sections alone — they are intentionally forward-looking and don't need to match current code:

- **Future directions / roadmap** — planned features, aspirational goals
- **Design philosophy / principles** — high-level design intent
- **RFCs / proposals** — draft ideas that haven't been implemented yet
- **TODO / wishlist sections** — explicitly marked as aspirational

If a section is ambiguous, err on the side of updating it. Only skip sections that are clearly and explicitly about the future.

## Workflow

1. Find all documentation files in the repo
2. Read each doc file
3. For each claim the doc makes about the code, verify it against the actual codebase
4. Fix everything that's wrong — edit in place, don't just report
5. Briefly summarize what was changed when done
