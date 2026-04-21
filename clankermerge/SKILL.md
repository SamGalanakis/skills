---
name: clankermerge
description: Controlled interactive rebase or merge. Auto-resolves obvious conflicts; groups the rest into feature-level decisions and asks the user one compact question at a time.
---

# Clankermerge

The agent drives the rebase/merge, silently resolves mechanical conflicts, and asks the user **feature-level** questions (not hunk-level) for anything that requires real judgment.

## Invocation

```
/clankermerge <target>         # rebase current branch onto <target> (default)
/clankermerge rebase <target>
/clankermerge merge <target>
```

If `<target>` is missing, assume `main` and confirm.

## Pre-flight

- Tree must be clean (`git status --porcelain` empty). Stop otherwise — do not auto-stash.
- `<target>` must resolve (`git rev-parse --verify`).
- Create backup: `git branch backup/<current>-$(date +%s)`. Tell the user the name.
- Refuse if a rebase/merge is already in progress; ask the user.

## The one rule that matters

**Ask at the level of "what does the user care about", not "which lines survive".**

Before writing any questions, scan every conflicted hunk across every file and cluster them:

- Hunks that implement the same feature, refactor, or naming choice → **one question** with a single decision applied across all of them.
- Hunks that are mechanically resolvable → resolve silently (see below).
- Only truly independent judgment calls get their own question.

Most real rebases collapse to 1–3 questions, not 20.

## Auto-resolve (no question asked)

- Non-overlapping hunks → take both
- One side unchanged → take the edited side
- Whitespace/format-only on one side → take the semantic side
- Identical edits → take either
- Both deleted the same file → accept deletion

Anything outside this list → cluster and ask.

## Asking the user

Use `AskUserQuestion`. Batch up to 4 independent clusters per turn.

**Shape of each question:**

- **Title**: the feature/choice in plain language — `Caching strategy for fetchUser` or `Config file location`
- **Context**: two one-liners — what each side is trying to do, written as intent, not diff:
  - `Ours: adds an in-memory LRU wrapper (3 files touched)`
  - `Theirs: adds a Redis-backed cache (2 files touched)`
- **Options**:
  1. `Ours`
  2. `Theirs`
  3. `Both` — only offer when it's actually coherent (e.g. additive changes); skip otherwise
  4. `Show the diff` — escape hatch to see raw hunks before deciding
  5. `Custom` — user describes or writes the resolution

`Abort` lives as a separate follow-up question if needed, not in the option list.

Once the user picks, apply that decision to **every** hunk in the cluster without re-asking.

## Rebase loop

1. `git rebase <target>`.
2. On stop: read conflicted files, parse hunks, auto-resolve the mechanical ones.
3. Cluster remaining hunks for the current commit. Header each question with `[commit <short> "subject"]` so the user knows what they're deciding inside of.
4. Apply decisions, `git add`, `git rebase --continue`.
5. Repeat until done or aborted.

## Merge loop

1. `git merge --no-ff --no-commit <target>`.
2. Walk all conflicted files at once, auto-resolve, cluster the rest.
3. Ask. Apply. `git add`.
4. Show a final summary and ask for go-ahead before `git commit`.

## Custom / show diff

If the user picks `Show the diff`, paste the cluster's hunks with 3 lines of context and re-ask. If `Custom`, take their instructions, write the resolution, show the final hunk back before staging.

## Abort

User can ask to abort any time. Run `git rebase --abort` or `git merge --abort`. Confirm tree is clean and remind them of the backup branch name.

## End-of-run

Report: clusters auto-resolved, clusters decided by user, files touched, backup branch. Suggest (don't run) the project's test command.

## Don'ts

- Don't ask hunk-by-hunk when hunks share a cause. Cluster first.
- Don't dump raw diffs by default.
- Don't offer `Both` when it would produce nonsense.
- Don't touch the backup branch or force-push.
