# Claude Code Global Dev Harness

Behavioral guidelines to reduce common LLM coding mistakes and let Claude work on its own once the goal is clear. Project-specific rules live in each repo's `CLAUDE.md` and `lessons.md`.

**Tradeoff:** these guidelines bias toward caution before coding and autonomy after. For trivial tasks, use judgment.

## 1. Think before coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State your assumptions explicitly.
- If multiple interpretations exist, present them — don't pick silently. If a simpler approach exists, say so; push back when warranted.
- If something is unclear, stop, name what's confusing and ask — before writing code, one question at a time, with a recommended default.
- Minor unknowns that a reasonable assumption covers: state the assumption and continue.

## 2. Simplicity first

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked, no abstractions for single-use code, no unrequested flexibility or configurability.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it. Would a senior engineer call it overcomplicated? Then simplify.

## 3. Surgical changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments or formatting; don't refactor what isn't broken; match existing style.
- Unrelated dead code: mention it, don't delete it. Remove only the imports/variables/functions that your change made unused.
- Never revert, overwrite or delete the user's unrelated work.
- The test: every changed line traces directly to the request.

## 4. Goal-driven execution

**Define success criteria. Loop until verified.**

- Turn tasks into verifiable goals: "fix the bug" → "write a test that reproduces it, then make it pass"; "refactor X" → "tests pass before and after".
- Multi-step tasks: state a brief plan, each step as `step → verify: check`.
- Once criteria are clear, loop on your own: implement, run checks, fix. After two failed fix attempts, stop and report with evidence.
- Done means verified by commands or explicit checks, never self-assessment.

## lessons.md — project memory

- Each project keeps a `lessons.md` at the repo root: the rules to know about this project. The SessionStart hook injects it into every session; follow it.
- After any user correction, or a mistake you find yourself, add a rule immediately — without being asked. Create the file if missing.
- Format: one bullet per rule, imperative, under a short theme heading: `- <rule>. Why: <reason>.`
- Keep it short: update or merge an existing rule instead of duplicating; delete rules that became wrong. Consolidate past ~150 lines.
- Only project-specific, durable rules. Cross-project preferences belong to Claude Code's built-in memory; one-off task details belong nowhere.

## Autonomy and safety

- Pick the workflow yourself; never make the user ask for review, tests or wrap-up.
- Reversible local actions need no confirmation: reading, editing, running tests/builds, creating a work branch.
- Always confirm first: commits (unless the user asked), `git push`, PR creation/merge, publishing, deleting user data. Never force-push.

## Workflow (scaled to the change)

- **Small** (one file, no contract change): implement, run the relevant check.
- **Medium** (a few files or a behavior change): implement → `review` subagent with `implementation-review` → `test` subagent with `test-code` → `wrap-up`.
- **Large** (new feature, cross-module, public contract): `planner` (`create-plan` → `plan-contest`) → `architecture` if structural → `frontend`/`backend` → review → `review-code` + `simplify-code` → `test` → `wrap-up`.
- `ship` runs this chain end to end. Built-in `/code-review`, `/simplify`, `/security-review` are valid substitutes.
- The `review` agent is read-only (no Bash): pass it the goal, plan path, `git diff` and check output.
- Delegate to subagents when it keeps the main context small or work can run in parallel; do small lookups yourself.

## Conventions

- Work on a branch for multi-file work: `git switch -c <type>/<short-name>`. Commits and PRs use the `commit` / `create-pr` nomenclature.
- Function/module comments use exactly these section labels, without colons or renamed variants: `Parameters`, `What it does`, `Output`.
- When a skill defines a template, follow it exactly.
- UI work goes through the `frontend` agent: root `DESIGN.md` is the source of truth (`create-design-md` if missing), `frontend-design` for visual direction, and the running app is verified in a browser (`webapp-testing`, `cmux browser`, Claude in Chrome or the built-in browser) with URL, console errors and screenshot evidence.

## Optional skills

Personal skills in the config repo's `optional/skills/` are active only if copied to `~/.claude/skills/`. `asset-research-skill` / `sector-research-skill` need the Notion MCP and must ask before Notion writes. `content-*` skills read their guides from `<vault-root>/Content Vault/guides/`, where `<vault-root>` = `~/Documents/ObsidianMemory`; if the guides are missing, stop and say so.

## Final response (medium/large tasks)

- Summary
- Files changed
- Commands run
- Failures or remaining risks
- Confidence

For questions and small changes, answer directly.

---

**These guidelines are working if:** diffs contain fewer unnecessary changes, fewer rewrites come from overcomplication, clarifying questions come before implementation rather than after mistakes, and the same correction never has to be given twice.
