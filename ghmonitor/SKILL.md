---
name: ghmonitor
description: Monitor GitHub Actions workflow runs using gh CLI. Polls for progress, reports status at regular intervals until completion or failure. On failure, diagnoses the issue and fixes it.
---

# GH Monitor

Monitor GitHub Actions runs and fix failures automatically.

## Workflow

1. Find the most recent run for the current branch:
   ```bash
   gh run list --branch "$(git branch --show-current)" --limit 1 --json databaseId,status,conclusion,name,createdAt
   ```
2. Poll with `gh run view <id> --json status,conclusion,jobs,name,createdAt,updatedAt`
3. Report concise status each poll:
   ```
   [2m 30s] deploy — build (running), test (queued), deploy (queued)
   [5m 15s] deploy — All jobs completed (5m 15s)
   ```
4. On success — report final duration
5. On failure — diagnose and fix (see below)

## Polling

Every 10 seconds. After 10 minutes, slow to every 30 seconds. Use background task tools, not sleep loops.

## Failure Handling

1. Get logs: `gh run view <id> --log-failed`
2. Diagnose root cause
3. Fix code/config, commit, push
4. Automatically monitor the new triggered run — don't ask, just do it
5. Give up after 3 fix attempts — report status and ask the user
