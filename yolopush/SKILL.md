---
name: yolopush
description: Quickly ship changes by staging all, committing, pushing to staging, merging to main, and returning to staging
---

# Yolopush

Ship it. No questions asked.

**Do NOT ask the user for confirmation at any step** (except merge conflicts). Stage everything, commit, push, merge, done. This is the whole point — zero friction, zero prompts.

## Steps

1. **Ensure staging branch exists** — If there is no `staging` branch locally or on the remote, create it from `main`: `git checkout -b staging main && git push -u origin staging`. If already on staging, continue.
2. **Stage ALL changes** — `git add -A` — stage everything in the repo regardless of origin, including untracked files, modified files, and deletions. No cherry-picking, no asking "should I include this?".
3. **Commit** — Create commit with appropriate message based on changes.
4. **Push to staging** — `git push origin staging`
5. **Merge to main** — `git checkout main && git merge staging && git push origin main`
6. **Return to staging** — `git checkout staging`

## Merge Conflicts

If the merge to main produces conflicts:

1. **Do NOT force or auto-resolve.** Stop and report to the user.
2. List each conflicting file with a brief summary of what conflicts (e.g. "src/main.rs — both branches changed the `init()` function").
3. Ask the user how they want to resolve: keep staging version, keep main version, or manual merge.
4. After resolution, complete the merge commit, push main, and return to staging.
