#!/usr/bin/env bash
# firehose fast-gate merger: admin-merges ready PRs as soon as the FAST gates pass.
# Usage: REPO=owner/name FAST="Lint,Build" HOURS=12 bash fast-merger.sh
#   REPO   GitHub repo (required)
#   FAST   comma-separated check names that must be SUCCESS (the fast gates)
#   HOURS  how long to run (default 12)
#   BASE   base branch (default main)
# Merges when: non-draft, MERGEABLE, no `hold` label, no AI attribution in its
# text, all FAST checks SUCCESS, and no check has already FAILED. Pending long
# jobs don't block. Prints one line per merge.
set -u
: "${REPO:?set REPO=owner/name}"
FAST=${FAST:-Lint}
BASE=${BASE:-main}
END=$(( $(date +%s) + ${HOURS:-12} * 3600 ))
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
while [ "$(date +%s)" -lt "$END" ]; do
  gh pr list -R "$REPO" --state open --base "$BASE" --limit 100 \
    --json number,isDraft,mergeable,labels,title,body,statusCheckRollup,id \
    > "$TMP" 2>/dev/null || { sleep 90; continue; }
  FAST="$FAST" python3 - "$TMP" <<'PY' | while read -r n id; do
import json, os, re, sys
fast = {s.strip() for s in os.environ["FAST"].split(",") if s.strip()}
ai = re.compile(r"co-authored-by: *(claude|codex|devin)|generated with \[claude|anthropic", re.I)
for p in json.load(open(sys.argv[1])):
    if p["isDraft"] or p["mergeable"] != "MERGEABLE":
        continue
    if any(l["name"] == "hold" for l in p["labels"]):
        continue
    if ai.search((p["title"] or "") + "\n" + (p["body"] or "")):
        continue
    concl = {c.get("name"): (c.get("conclusion") or c.get("state") or "").upper()
             for c in (p["statusCheckRollup"] or [])}
    if any(v in ("FAILURE", "CANCELLED", "TIMED_OUT", "ERROR") for v in concl.values()):
        continue
    if not all(concl.get(g) == "SUCCESS" for g in fast):
        continue
    print(p["number"], p["id"])
PY
    gh api graphql -f query='mutation($id:ID!){dequeuePullRequest(input:{id:$id}){clientMutationId}}' -f id="$id" >/dev/null 2>&1
    if gh pr merge "$n" -R "$REPO" --admin --squash >/dev/null 2>&1; then
      echo "$(date -u +%H:%M) MERGED #$n"
    else
      echo "$(date -u +%H:%M) merge-failed #$n"
    fi
  done
  sleep 90
done
