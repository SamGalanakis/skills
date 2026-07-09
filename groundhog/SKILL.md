---
name: groundhog
description: "Mine all local Claude/Codex session traces for recurring interaction patterns and friction, then present a concise numbered report of improvement opportunities (automation, AGENTS.md/CLAUDE.md rules, precommit hooks, skills, new tools, prompting patterns, or anything else that fits). Strictly read-only: it recommends and stops — no changes until the user picks recommendations by number. Use when the user wants to understand how they work with coding agents and what to improve."
---

# Groundhog

Relive the user's agent sessions to spot the patterns they repeat every day. The main agent orchestrates a sweep over all local Claude Code and Codex traces, fans out reader subagents to mine them for recurring workflows and friction, and synthesizes a numbered report of improvement opportunities. It then **stops**: no file edits, no installs, no config changes until the user replies with the numbers they want implemented.

## Data Sources

- **Claude Code**: `~/.claude/projects/<flattened-cwd>/<session-uuid>.jsonl` — one file per session. User messages carry `promptSource`, `entrypoint`, `isSidechain`, `permissionMode`, `cwd`, `gitBranch`, and timestamps.
- **Codex**: `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl` — first line is a `session_meta` payload with `originator`, `source`, `cwd`, and model info. `~/.codex/history.jsonl` holds raw prompt history.

Verify what actually exists before planning the sweep — trace formats and locations drift across CLI versions, and other agent CLIs (Gemini, opencode, …) may also have local traces worth including. A quick `head` of a few files beats assuming the layout above is still exact.

## Inputs (all optional)

- **Analysis budget.** Default: up to **500 user messages** (human-typed prompts, with their surrounding session context), walking sessions **newest-first**, going back at most **60 days**. Whichever limit hits first ends the scope. The user may raise, lower, or drop either bound ("all history", "last 2 weeks", "2000 messages").
- **Project filter.** Default: all projects.
- **Tool filter.** Default: every agent CLI with local traces found.

Recent sessions matter most — they reflect current habits, current projects, and friction that is still live. Older sessions are only worth reading if the budget allows after the recent ones are covered.

## Provenance: user sessions vs agent-driven sessions

Sessions started by the user and sessions started by another agent (e.g. Claude invoking `codex exec`, headless `claude -p`, subagent sidechains) must **never** be mixed — an agent's machine-generated prompts say nothing about the user's habits. Classify every session before any analysis:

- **Codex**: `session_meta.originator` — interactive values like `codex-tui` / `codex_cli_rs` mean human; `codex_exec` (and custom originators from the user's own tools) mean agent-driven. `source: "exec"` likewise means agent-driven.
- **Claude**: first user message with `promptSource: "typed"` means human; `promptSource: "sdk"` or `entrypoint: "sdk-cli"` means agent-driven; `isSidechain: true` messages and agent transcript files are subagent work.
- **Fallback**: when metadata is missing or unclear, the first user message itself is usually a giveaway — humans type short, informal, typo-prone prompts; agents inject long structured instruction blocks. If still unclear, label the session `ambiguous` — never force a binary call.

User sessions drive the "how the user works and what would help them" analysis. Agent-driven sessions get their own separate pass with a different question — "what is the user's automation doing repeatedly, wastefully, or badly" — reported in their own section.

## Pipeline

The main agent orchestrates and synthesizes; readers are subagents. Write any helper code as throwaway scripts in the scratchpad — nothing is checked in and nothing outside the scratchpad is written.

1. **Inventory (scripted, no LLM per file).** Write a small throwaway script that sweeps the trace trees and emits a manifest: per session — tool, project, date, provenance label, turn counts, human-message count, interrupt count, permission mode, size/duration. Thousands of files should be inventoried by code, not by reading each one.
2. **Select and shard.** Sort sessions newest-first and take them until the analysis budget is spent — counting user messages against the message cap and stopping at the time bound. Then group the selection by project and cut token-bounded batches (roughly 10–20 sessions each, splitting oversized sessions). Note explicitly where the budget cut off and what fell outside it.
3. **Fan out readers.** Spawn parallel reader subagents, one per batch. Each reads its sessions and returns **structured findings only**: pattern observed, frequency, session IDs, one short illustrative quote, and a suggested improvement. Give readers the friction lens below *as examples, not a checklist* — an observation that fits no listed category is exactly as welcome. Agent-driven batches get the automation-audit question instead.
4. **Synthesize.** Dedupe findings across batches, merge frequencies, and rank by frequency × friction cost × ease of fix. A fresh synthesis subagent is worth it when finding volume is high; otherwise the orchestrator merges directly.
5. **Report and stop.** Print the report (format below) and end the turn. Implement nothing until the user replies with numbers.

## What to look for

These are **examples to prime the readers, not boundaries**. Recommend whatever would genuinely help — different prompting patterns, extra tools or MCP servers to install, workflow changes, shell aliases, model/mode choices, session hygiene, anything — even if it fits no category here:

- Corrections or preferences the user re-states across sessions → candidate CLAUDE.md/AGENTS.md rule.
- Interrupted or abandoned turns → prompting or plan-mode pattern the user might adopt.
- Permission-prompt churn on the same safe commands → allowlist entries.
- The same multi-step ritual typed out repeatedly → candidate skill or slash command.
- Lint/test/build failures caught late and fixed post-hoc → precommit hook or CI step.
- The same setup/build/run incantations rediscovered each session → script or Makefile target.
- Project context re-explained every session → CLAUDE.md/CONTEXT.md content.
- Tool failures, retries, or missing capabilities → tooling fix, MCP server, or new tool to install.

## Report format

```
Groundhog report — {N} sessions ({H} user / {A} agent-driven / {X} ambiguous), {P} projects, {date range}
Coverage: {what was read vs sampled/skipped, one line}

Recommendations
1. {pattern, one line} — seen {n}× across {projects}. e.g. "{short quote}" ({session ref})
   → {concrete intervention} · effort {low|medium|high}
2. …

Agent-driven sessions
{numbered continuation, same shape — or "nothing notable"}

Reply with numbers to implement.
```

Keep each recommendation to ~3 lines: the pattern with evidence, then the intervention. Order by impact. Ten sharp recommendations beat thirty vague ones.

## Guardrails

- **Read-only until prompted.** The report is the deliverable. No edits, installs, or config changes — not even "obviously good" ones — until the user picks numbers.
- **Traces contain secrets.** Readers must never quote credentials, tokens, or keys; keep excerpts short and redact anything sensitive. Everything stays local.
- **Keep provenance clean.** A finding sourced from an agent-driven session must never appear as a user habit.
- **Disclose coverage.** Sampling, skipped sessions, unparseable files — say what was dropped; silent truncation reads as "covered everything".
- **Evidence or it doesn't ship.** Every recommendation cites real sessions. No plausible-sounding advice without traces behind it.
