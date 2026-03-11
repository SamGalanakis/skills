---
name: localref
description: Clone a GitHub repo or download a reference source locally to /tmp/ for searching and reading. Use when you need to reference external code, docs, or examples to complete the current task.
---

# Localref

Clone or download external references to `/tmp/` for local searching and reading.

## Workflow

1. **Clone** — shallow clone to `/tmp/ref-<name>`:
   ```bash
   git clone --depth 1 https://github.com/owner/repo.git /tmp/ref-<name>
   ```
   For a specific branch/tag: add `--branch <ref>`.
   If `/tmp/ref-<name>` already exists, reuse it.

2. **Search and read** — grep, glob, read files to find what you need.

3. **Apply** — use findings to complete the task in the working repo.

For non-git sources (tarballs, zips): `curl -L <url>` into `/tmp/ref-<name>` and extract.

## Rules

- Never modify the reference copy
- Never copy files wholesale — read, understand, write your own code
- Respect licenses — comment the source if code is substantially derived
