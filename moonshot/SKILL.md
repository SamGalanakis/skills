---
name: moonshot
description: "Push a feature past the conventional default: strip it to first principles, ask what world-class looks like for the underlying problem, hunt the frontier wherever it lives (research, other industries, legendary implementations, adjacent fields), and return ranked, implementable techniques the project has left untapped. Use when the user wants a feature to feel special instead of like every other app, asks 'what would the best version of this look like', or wants out-of-the-box approaches mined for a practical problem."
---

# Moonshot

The default implementation of anything is the one every other app already
has. If you want the result to be special, you have to get to the frontier
first — and the frontier is usually further away than people think, hiding
behind a framing gap: "nice-looking tables" doesn't *sound* like it has
decades of deep work behind it, but line-breaking optimization does. The
skill is that jump: first principles down, then frontier out.

The output is not a survey. It is a short ranked list of approaches this
project could actually adopt, each grounded in something real and stated as
an implementable mechanism.

## Arguments

Free-form. A feature, module, or problem statement scopes the round
("table rendering", "the diff view", "our retry logic"). Invoked bare, infer
the target from the preceding context; if there is no active feature in
context, ask what to aim at rather than surveying the whole repo.

## The pipeline

### 1. Strip to first principles

This is the step that creates all the value; do not rush it. Forget how this
feature is usually built. Ask instead:

- what is the actual problem underneath the product framing? What is being
  optimized, allocated, ranked, laid out, synchronized, guessed?
- if there were no convention to copy, what would a great solution have to
  do? What does "world-class" even mean for this — measurably, not vibes?
- who else has this problem in disguise? Typography has it, games have it,
  databases have it, aerospace has it — the best solution often lives in a
  field that doesn't share your vocabulary.

Write down 3–6 reframings of the problem, favoring the non-obvious ones. The
conventional framing goes on the list too, explicitly, so it competes instead
of winning by default.

### 2. Establish the project's current altitude

Read the relevant code. Note what approach it takes today (even if that's
"proportional split by character count" or "retry three times with sleep"),
where it visibly falls short, and the constraints any replacement must
respect: language, dependencies, performance budget, input scale. A frontier
technique that violates a hard constraint is trivia, not a finding.

### 3. Hunt the frontier, wherever it lives

For each reframing, go find the best known work — exhaustively, not the first
page of results. The frontier is scattered:

- research and papers, when the problem class has them (often it does, and
  nobody looked);
- legendary implementations: TeX's line breaker, a game engine's culling
  pass, a browser's layout engine, a database's scheduler — read the actual
  code where it's public, the compromises are part of the lesson;
- other industries' standard practice that your industry never imported;
- old solutions from when the constraint was harder — scarcity-era
  engineering often beats the modern default.

Use whatever search and research capacity the environment provides, and fan
reframings out to parallel research agents where available.

Grounding rules: every candidate names something real and checkable — a
paper, an algorithm, a repo, a shipped system. Never cite from memory alone;
confirm it exists before it appears in output. Capture each approach as a
mechanism (the recurrence, the objective function, the data structure, the
trick), not as a topic name.

### 4. Filter to what is untapped and worth it

Cut the list hard:

- drop anything the project already does, even crudely — unless the frontier
  version is a step-change, in which case state the delta precisely;
- drop anything that violates a step-2 constraint;
- drop cleverness with no payoff at this project's scale or inputs;
- keep negative results: "looked at X, needs GPU-scale batching, skip" saves
  the next round from re-deriving it.

The frontier is the starting point, not the ceiling — once you're standing
on the best known work, note where this project could go *past* it, and say
so as a candidate of its own.

### 5. Output

Ranked candidates, best first. Each one states:

- **the approach**, named, with its source;
- **the mechanism** in a few sentences — enough that an implementer starts
  from understanding, not from a reading list;
- **what it buys here**, tied to a concrete weakness of the current code;
- **adoption cost**: rough size, risky parts, and what to prototype first.

Close with the "considered, not adopted" list. If the user asked for
implementation, take the top candidate through their environment's normal
build-and-review process; otherwise stop at the report — the reframing and
the ranked list are the deliverable.

## Repeat runs

The frontier moves and the project moves. On a repeat pass over the same
feature, carry forward the considered-not-adopted list, check whether adopted
approaches were implemented faithfully (a mangled frontier technique is worse
than the honest naive one), and spend the hunt on reframings the last round
under-covered.
