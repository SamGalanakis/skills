---
name: status
description: "Report where an ongoing thread, arc or project stands: a one-line verdict against the goal, what changed since the user last looked, what is moving, what is stuck, what comes next, and what needs the user. Checks live state first and writes in plain words. Use when the user says status, status?, where are we, how are we doing, making progress?, what happened overnight, catch me up, state of X, status for standup, or asks for a pasteable update."
---

# Status

The user wants to know whether things are on track and whether they need to
do anything. Give them that in under a minute of reading.

## 1. Pick the altitude and audience

Read the ask and pick one of these:

- **Project** (the default, for "status", "where are we", "how are we doing"):
  the goal, progress toward it, the arcs, and the risks. Leave out the
  machinery (lanes, PIDs, loops, worktrees) unless it is the problem.
- **Thread or work** ("making progress?", "is it stuck?", "what's
  running"): is the work actually advancing, how long it has been running
  against how long it should take, and whether it is wedged.
- **Since X** ("overnight", "since last night", "since I last messaged"):
  only the delta.
- **Outside readers** ("for standup", "something I can paste"): features
  and outcomes only. No ticket noise, no internal names, no process.
- **Shape requests** ("concise", "table vs goals", "done → in progress →
  todo"): follow the requested shape exactly. "Concise" means 8 lines or
  fewer.

## 2. Check live state before writing

Don't report from memory. Look at what moves: CI and main, open PRs,
lanes or agents and their last activity, the tracker, and benchmark
results. Anything you could not check gets marked as stale with its
age. While you look, watch for:

- **Stalls:** work that hasn't progressed in far longer than it should
  take, dead loops, or a PR or remote that is behind.
- **Idle capacity:** nothing is working on a known red or an open item.
- **Drift:** effort is going somewhere the goal doesn't need, such as
  chasing parity nobody asked for or polishing past diminishing returns.

If you are the orchestrator and the fix is obvious and reversible
(relaunch, dispatch, rebase), fix it, then report it in one line. Don't
make the user ask.

## 3. Write it

- **Verdict first.** In one line: on track, slow, stalled, blocked or red,
  measured against the goal. Answer the literal question ("making
  progress?" → yes or no, then why).
- **Plain words.** Every item says what it means for the product. IDs go
  last, in parentheses, as references only: "faster session restore
  (FIG-5137)", never "FIG-5137 landed". Don't use undefined codenames,
  ruling numbers or row labels. If the user would have to ask "what is
  that?", rewrite it.
- **Numbers against targets.** Write "1.23× C, target 1.25×", not "SAXPY
  improved". Give counts with a denominator: "12 of 186 red".
- **Outcomes, not activity.** What landed and what it unlocks, not what
  was attempted.
- **Each "needs you" item stands alone.** Phrase it as a question with
  one line of context and your recommendation. With more than 2, offer
  to take them one at a time (/gavel).
- **Short.** It should fit on one screen. Fold detail into "ask for
  more". Use a table only for 4 or more like items, or when asked for one.

## Template (loose: drop empty sections, reorder to fit the ask)

```
**<Project or arc>: <verdict> (as of HH:MM)**
Goal: <what done means>. Progress: <measure vs target, e.g. 9/14 arcs, main 12/186 red>

Since <last check>:
- <outcome in plain words> (<ref>)

In flight:
- <workstream>: <state>, <next signal or ETA>

Stuck / at risk:
- <item>: <why>, <what is being done or what would unstick it>

Next: <the next 1–3 moves, in order>

Needs you:
1. <decision as a question>? <one-line context>. I'd <recommendation>.
```

For a status board or a pinned summary, use the same order in 8 lines or
fewer, with no prose, and update it only when something significant
changes.
