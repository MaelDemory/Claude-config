# Claude Code Global Dev Harness

Adapted from the OpenCode harness (`AGENTS.md` + `.opencode/`). Global rules should keep agents useful. Project-specific details belong in each repo's `CLAUDE.md`.

## How OpenCode primary agents map to Claude Code

Claude Code has no switchable primary agents; their roles are covered natively:

- `cto` (orchestrator) → the main session itself, following the routing rules below.
- `plan` → built-in **Plan Mode** (`shift+tab`) for read-only planning; delegate writable `PLAN-*.md` / `TASK_CONTEXT.md` artifacts to the `planner` subagent.
- `ask` → ask questions in the main session; do not edit files when the user is only asking a question — report findings and stop.
- `build` → the main session executing the build chain below.

## Subagents (`.claude/agents/`)

- `planner` — writable planning: PLAN files, TASK_CONTEXT handoffs, uses plan-contest.
- `plan-contest` — neutral challenge of plans before implementation.
- `architecture` — code architecture, module boundaries, diagrams, and structural docs.
- `frontend` — UI implementation with `frontend-design`, component reuse, accessibility, contrast, cmux visual checks, and anti-slop review.
- `backend` — APIs, data flow, persistence, modular services, validation, and production-quality server code.
- `review` — read-only implementation review against the plan and task.
- `test` — independent test design/writing from the plan/spec, not the implementation.
- `cartography` — codebase documentation and map generation.
- `indexer` — repo/vault index creation from docs and cartography.
- `kanban` — vault kanban search/create/update using templates.
- `file-system` — safe file/project/config navigation and search.
- `github` — commit/PR workflow only when explicitly requested.
- `vault` — ObsidianMemory search/write/update using `<vault-root>` (see Vault configuration).

`plan-contest`, `review`, and `file-system` are enforced read-only via `tools: Read, Grep, Glob` in their frontmatter — not just by prose instructions.

Skills live in `.claude/skills/` and keep their OpenCode names (`create-plan`, `grill-me`, `wrap-up`, etc.), with two renames to avoid collisions: `simplify-code` (a `simplify` built-in exists in Claude Code) and `cartography-map` (the `cartography` subagent keeps that name).

## Repo harness files

- Use `write-agents-md` when creating or updating repo `AGENTS.md`/`CLAUDE.md`, `PROGRESS.md`, `DECISIONS.md`, `feature_list.json`, or vault progress mirrors.
- Treat the repo harness file as a short router, not an encyclopedia; put detailed rules next to the code they constrain.
- For durable work, prefer repo state files plus ObsidianMemory Dev Vault/PM records over chat history.
- When a kanban task exists, keep repo `PROGRESS.md`, `feature_list.json`, vault progress, and kanban status aligned.
- WIP = 1 by default: one active feature/task until verified, blocked, or explicitly reprioritized.

## Session state discipline

- Clock in before durable project work: read repo `CLAUDE.md`/`AGENTS.md`, `PROGRESS.md`, `DECISIONS.md`, `feature_list.json`, vault progress, and matching kanban task when present.
- Clock out after durable project work: record verification evidence, update repo progress/feature state, and mirror vault/kanban status when configured.
- If repo, vault progress, and kanban disagree, report the mismatch and avoid marking work done until evidence resolves it.
- Completion is evidence-gated: passing means verified by commands or explicit manual checks, not agent self-assessment.
- Keep volatile state in `PROGRESS.md`/vault progress, not in global instructions, so the stable harness stays short and cache-friendly.

## Default workflows

### New project
1. Start in the main session (orchestrator role).
2. `grill-me`
3. `vault` subagent + `create-project` when a vault project should be created.
4. `write-agents-md` for the repo harness file and state files when a repo exists.
5. Plan Mode or `planner` subagent.
6. `create-plan`
7. `plan-contest`
8. Revise plan until build-ready.

### Existing codebase onboarding
1. `onboard-project`
2. `cartography` subagent
3. `write-agents-md` if the repo lacks a short agent guide, state files, or verification commands.
4. `create-doc`
5. `indexer` subagent
6. `create-index`
7. `vault` subagent + `memory-write` when knowledge should be persisted.

### Existing project task
1. `start-session`
2. `vault-search` and/or `kanban-search`
3. `grill-me` if requirements are vague.
4. Plan Mode or `planner` subagent, with `create-plan` + `plan-contest`.
5. Build chain.

### Build chain
For meaningful implementation work, proactively run this chain:

1. Delegate to `frontend` and/or `backend` subagents.
2. Use `architecture` for structural decisions.
3. For UI work, require `frontend-design`.
4. Run `implementation-review` with the `review` subagent.
5. Run `review-code`.
6. Run `simplify-code` and apply clear simplifications.
7. Ask the `test` subagent to write/validate tests with `test-code`.
8. Finish with `wrap-up`.

The user should not need to manually request review, simplify, test, or wrap-up after every build.

## Coding discipline

- Make the smallest correct change that satisfies the plan/request.
- Avoid unrelated cleanup, broad rewrites, speculative abstractions, and 1000-line files.
- Ask only blocking questions; otherwise make a reasonable assumption and continue.
- In large or syntax-dense files, patch one coherent requirement at a time and verify quickly.
- When a skill defines a required template or nomenclature, follow it exactly; do not freestyle section names.
- Function/module comments must use exactly these section labels, without colons or renamed variants: `Parameters`, `What it does`, `Output`.
- Commit/PR work must use the configured `commit` and `create-pr` nomenclature, and only when explicitly requested.
- UI/frontend work must check root `DESIGN.md`; if missing for meaningful UI work, create or propose it using `frontend-design`.
- UI/frontend work with a runnable app should use `cmux browser` for visual/runtime verification when available, and report URL, commands, console/errors, and screenshot/snapshot evidence.
- Simplification must focus on recently modified code, preserve behavior, and avoid broad speculative refactors.
- Preserve user work. Do not revert, overwrite, delete, or clean up unrelated changes unless explicitly requested.
- Do not commit, push, or create PRs unless explicitly requested.

## Vault configuration

Single source of truth for vault locations — agents and skills reference these placeholders instead of hard-coded paths:

- `<vault-root>` = `~/Documents/ObsidianMemory` (edit here only to relocate the vault).
- `<legacy-vault-root>` = `~/Documents/ObsidianLegacy` (historical notes; optional).
- On Windows, resolve `~` explicitly to the user profile (`$env:USERPROFILE`); note that `Documents` may be redirected to OneDrive (`C:\Users\<user>\OneDrive - <org>\Documents`) — use the real resolved path.
- Vault folder names contain spaces (`Dev Vault`, `Content Vault`): always quote vault paths in shell commands.
- If `<vault-root>` does not exist, vault/kanban/memory skills must report "not configured" and continue; never fail the task over a missing vault.

## Vault rules

- Configured supervault: `<vault-root>` (see Vault configuration above).
- Code project memory: `<vault-root>/Dev Vault/projects/<project>/`.
- Cross-project records/tasks: `<vault-root>/PM/Projects/` and `<vault-root>/PM/Tasks/`.
- Prefer `vault-search` and indexes before broad vault scans.
- Ask before bulk vault writes, deletes, renames, or cross-vault changes.
- Use `memory-write` only for durable, reusable knowledge with evidence.

## Optional skills (not installed by default)

Personal content/investment skills live in `optional/skills/` in the starter repo and are only active if manually copied to `~/.claude/skills/`. When installed:

- Use `asset-research-skill` when the user asks to analyze, create, or update an investment asset/company (requires the Notion MCP and a matching Assets database).
- Use `sector-research-skill` for investment sector/theme analysis, company universes, and multi-asset pages.
- `content-post` / `content-article` / `content-weekly` require the Content Vault guides under `<vault-root>/Content Vault/guides/`; if the guides are missing, say so and stop instead of improvising the voice rules.
- Investment research must research first, prefer primary sources, search existing Assets before create/update, and ask confirmation before Notion writes.

## Verification

- Run relevant checks after edits when available.
- Explain what each verification proves.
- If checks fail, fix in scope up to two times, then report remaining risk.

## Final response

- Summary
- Files changed
- Commands run
- Failures or remaining risks
- Confidence
