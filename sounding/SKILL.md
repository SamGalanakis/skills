---
name: sounding
description: "Read where a project stands, meaning the current conversation, upcoming milestones and tickets, recent changes and trouble, and what has already been run, then return a plan of which skills to run: what to run now and why, then what to run later and why the rest are deferred. Most useful for project-wide passes such as audits, reviews, benchmarking and ideation, but any installed skill can make the plan. If the project needs a kind of pass no installed skill covers, it says so and suggests finding or creating one. Advises only: it runs nothing."
disable-model-invocation: true
---

# Sounding

Take a depth reading before choosing a course. Read where the project
stands, then return a short plan of which skills are worth running now,
which come later, and why the rest can wait.

This skill advises only. Do not run the recommended skills, edit files,
file tickets, commit or push. Read-only commands are fine. Keep the
survey quick: it's a sounding, not an audit.

## Candidates

Consider every installed skill. Read their names and descriptions at run
time; never work from a fixed list. Project-wide passes such as audits,
reviews, benchmarking and ideation are the usual picks, but a planning,
cleanup, docs or design skill can be the right answer.

When several skills overlap, pick the one whose description best fits
the evidence, and say in one line why it beats the others.

## Inputs

Read the project's situation first, then check skill history. Rough
order of weight:

1. **The conversation.** What the user is working on, worried about or
   about to start. A stated concern outweighs any inferred signal.
2. **What's coming.** Upcoming milestones, releases, open tickets and
   planned features. Aim passes at what's about to be built on or
   shipped, not only at what already changed.
3. **Recent trouble.** Incidents, regressions, flaky tests, fix-forwards,
   slowdowns and areas that keep reopening.
4. **Recent change.** Where the work has gone lately, new subsystems,
   and shifts in direction.
5. **Skill history.** What ran, when, and how much of its backlog is
   still open. Use it to rule skills out (too recent, backlog not done,
   stopped finding things). Never let it be the main reason to pick one.

Use whatever sources the project has: git history, the issue tracker,
docs and notes, and local agent session history (skill invocations and
the reports they produced). Skip what's missing, and don't assume any
particular layout or path.

## Output

Return a short plan: most of it on what to run now, with later and
deferred picks at the end. Every entry gives a reason tied to evidence
(a date, a change in direction, open findings, a recent incident, an
upcoming milestone), not a hunch. Add a focus only when one area clearly
stands out; otherwise the skill runs on the whole project.

- **Run now**: one to three skills, in order.
- **Run next**: skills that depend on something else landing first.
- **Deferred**: one line per relevant skill left out, with the reason.
  Skip skills that are plainly irrelevant.
- **Missing**: only if a gap matters now (see below).

If no skill is worth running now, say so, and point to the open backlog
or the next milestone instead.

### Example

**Run now**
1. `<skill-A>`: never run here, and the core data model has changed a
   lot since `<date>`.
2. `<skill-B>`, focused on `<area>`: `<milestone>` ships next and builds
   on `<area>`, which also has most of the recent fix-forwards.

**Run next**
- `<skill-C>` after `<skill-A>`'s fixes land: re-checks once the shape
  settles.

**Deferred**
- `<skill-D>`: ran 5 days ago, and most of its findings are still open.
- `<skill-E>`: the last three runs found little new. Wait for a new
  direction.
- `<skill-F>`: nothing relevant has changed since it last ran.

**Missing**
- A `<kind of pass>` pass: `<evidence it's needed now>`, and no installed
  skill covers it. Look for an existing one first, or create one.

## Missing skills

If the evidence calls for a kind of pass no installed skill does well,
list it under **Missing** with the same evidence standard as the other
picks. Name the kind of pass, not a skill name. Suggest searching for an
existing skill before creating one. Only list gaps that matter now; this
isn't a wishlist.
