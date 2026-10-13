---
name: gavel
description: "Put the decisions that need the user's judgment to them one at a time, and handle everything else directly. Gathers the candidate items (tickets, findings, open questions, a plan), checks each premise, does the clear, trivial and obvious ones without asking, closes stale ones, then grills the rest one by one in plain prose with context, a concrete example, the current-vs-proposed picture and a recommendation. Use when the user says grill, grill me, lets grill, anything to grill, what needs my call, what's waiting on me, ratify, go through the decisions 1 by 1, or asks to stress-test a plan or design."
---

# Gavel

The user's attention is the scarce resource. Spend it only on calls that
need their judgment. Do everything else yourself, say what you did in a
line, and move on.

## 1. Gather

Work out what is being grilled:

- **Named items**: tickets, findings, a pasted list, a plan or doc. Use them.
- **"Anything to grill?" / "what's waiting on me?"**: sweep for open
  decisions. Look at the conversation, the tracker (tickets marked as
  needing a ruling, design, or input; tickets blocked on the user), open
  questions in plans, specs and ledgers, and findings from recent audits
  or reviews. List what you found before triaging.
- **A plan or design to stress-test**: walk its decision tree and turn each
  unresolved branch into an item. Resolve dependencies in order: a
  decision that others hang on comes first.

## 2. Verify before asking

Facts are yours to find; only decisions go to the user. For each item:

- Is the premise still true at the tip of main? Is the bug still there,
  is the gap real, has someone already landed it?
- Was it already decided? Check ADRs, design docs, earlier rulings in the
  ticket and this conversation. A prior ruling that covers it settles it.
- What does the code do today? You will need this for current-vs-proposed.

With more than a handful of items, fan the checks out to subagents (one
per item or small group) and keep their conclusions, not their dumps.

## 3. Triage

Sort every item into one bucket:

- **Clear**: do it directly. The test: the user would almost certainly say
  "agree" without asking anything. Typical cases: trivial or mechanical
  fixes, one obviously right answer, a direct consequence of an existing
  ruling or ADR, a confirmed bug with an obvious fix, follow-ups that
  only restate agreed scope.
- **Stale**: the premise is false, already done, superseded, or a
  duplicate. Close or amend it with a one-line reason. If it is partly
  still relevant, reinvestigate and treat the live part as a new item.
- **Needs the user**: genuine judgment. Typical cases: a tradeoff between
  things they value (speed vs. safety, simplicity vs. capability), product
  or UX direction, scope or milestone placement, public contracts and
  durable formats, anything hard to reverse, overturning an ADR or earlier
  ruling, options that are close, or a recommendation you hold with low
  confidence.

When unsure between clear and needs-the-user, it needs the user. Never
treat as clear anything irreversible or outward-facing that the user has
not already approved.

Then report the triage once, compactly:

```
Doing directly (say "hold N" to pull one back):
  1. FIG-123 (fixture rename): mechanical, follows ADR 0042
  2. ...
Closing as stale:
  3. FIG-456: fixed in a1b2c3d
To grill, in this order:
  4. FIG-789: should Stop kill unawaited child processes?
  5. ...
```

"Doing directly" means the session's normal action for settled work:
dispatch it, ticket it, or fix it, as the user's request implies. If they
said "no implementation, just grill", it means updating the ticket or doc
only. Start the clear work immediately and keep it running in the
background while the grill goes on.

## 4. Sharpen each item before presenting it

The user's usual pushback is predictable. Answer it in advance:

- **Wholehog end-state.** Recommend the clean end-state, not a patch on
  the current shape, unless they asked for a stopgap.
- **Treat like things alike.** If the proposal handles one kind of thing
  differently from its siblings, either justify the difference in one
  sentence or remove it.
- **Every part earns its place.** If option 4 alone solves it, don't
  recommend "4 plus a backstop" unless the backstop covers a named case.
- **Simpler way?** Ask whether a smaller change gets the same result.
- **What do others do?** When the question has an industry answer
  (protocols, storage, retries, caching, agent harness behaviour), find
  out what reputable references actually do, with file or doc citations,
  before recommending. Default to matching common practice over our own
  quirks unless there is a stated reason not to. A subagent can run this
  check while you present earlier items.

## 5. Grill one at a time

Present exactly one item per message, in plain prose. Do not use the
multiple-choice question tool. Each item has:

1. **Header**: `Ruling 4 of 9: FIG-789, <the question in plain words>`.
2. **What this is about.** Two or three sentences a smart outsider would
   follow. Define any term the user may not have in their head right now.
3. **Today vs. proposed.** What happens now, what would change, and why
   it matters now (what it blocks, what it costs).
4. **A concrete example.** One real scenario with real names and values:
   "you press Stop while `cargo test` is running in a background shell;
   today ..., under (A) ...".
5. **Options**: two to four, lettered, each with what changes and what it
   costs. Use a table when comparing several options or references.
6. **Recommendation**: the option, why, and how confident you are. If
   confidence is low, say what would raise it.
7. **One closing question** answerable with "agree" or a letter.

Aim for enough context to decide without a follow-up, and no more. Plain
words beat dense ones: write it the way /bro would on the first try.

## 6. Handle the reply

- **"agree", "ok", "yes", "go with recommended", a letter**: record the
  ruling where it lives (the ticket, ADR, spec or doc), take the follow-on
  action (ticket, dispatch, or amend as the session implies), add a one-line
  confirmation, and present the next item in the same message.
- **Partial agreement** ("agree on 1 and 3, explain 2"): apply exactly
  what was agreed, nothing wider, then deal with the rest.
- **A question or pushback**: answer it directly. If it shows the
  recommendation was wrong, say so, revise, and re-ask. If you still hold
  the recommendation, give its strongest case and your confidence; do not
  flip just because you were questioned.
- **"/bro", "more context", "examples", "unclear"**: re-explain the same
  item more simply with another example. Use that depth for every item
  after it.
- **"check what others do", "ask astra", "prospect this"**: run the lookup
  or consult, come back with the result, and re-present the item.
- **"later", "park", "not now"**: mark it parked with the reason and move
  on.
- **A new decision surfaces mid-grill**: triage it like the rest. Do it
  directly if it is clear; otherwise append it to the queue and say so.

## 7. Keep a ledger

Grills outlive context windows. Keep a short ledger file (the session
scratchpad, or the project's notes directory if it has one) with one line
per item: id, bucket, ruling, the user's reply verbatim, and where the
ruling was recorded. Update it after every reply.

**"refresh me" / "back to the grill"**: give the decided items in one line
each, then re-present the current item in full, then list what remains.

## 8. Finish

When the queue is empty, report:

- the rulings, one line each, with where each was recorded;
- what was done directly, and its status;
- what was closed as stale;
- what was parked, and why.

Then stop. Implementation of grilled items starts only if the user's
request already covered it or they say go.
