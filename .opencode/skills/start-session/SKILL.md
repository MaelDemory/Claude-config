---
name: start-session
description: Start-session, prepare existing project context, load vault notes, or check kanban before planning/building. Use by CTO when durable project context matters.
---
# Start Session

## Required session context template

```markdown
## User goal
- <current request>

## Project context
- Repo/project: `<path or name>`
- Vault notes: `/Users/hugo/Documents/ObsidianMemory/...` / none found
- PM task: `/Users/hugo/Documents/ObsidianMemory/PM/Tasks/<task>.md` — <status> / none found
- Dev kanban: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/kanban.md#<task>` / none found

## Repo harness state
- Agent guide: `AGENTS.md` / `.opencode/AGENTS.md` / missing
- Progress: `PROGRESS.md` — <current state or missing>
- Decisions: `DECISIONS.md` — <constraints read or missing>
- Feature list: `feature_list.json` — <active feature/status or missing>
- Verification command: `<command>` — <source or missing>

## Vault / kanban alignment
- Dev Vault project: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/_project.md` / none configured
- PM project: `/Users/hugo/Documents/ObsidianMemory/PM/Projects/<project>.md` / none configured
- Matching PM task: `/Users/hugo/Documents/ObsidianMemory/PM/Tasks/<task>.md` — <status> / none found
- Matching Dev kanban item: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/kanban.md#<task>` — <status> / none found
- Alignment: <repo/vault/kanban agree, mismatch, or unknown>

## Relevant facts
- <fact with source path>

## Missing context
- <question only if blocking>

## Recommended route
- `ask` / `plan` / `build` / `vault` / `kanban` — <why>
```

Steps:
- Identify project/repo and user goal.
- Read the repo agent guide first: prefer root `AGENTS.md`, then `.opencode/AGENTS.md`.
- Clock in from repo state files when present: `PROGRESS.md`, `DECISIONS.md`, `feature_list.json`.
- Search `/Users/hugo/Documents/ObsidianMemory` with `vault-search` when durable context matters.
- Search kanban if a task/ticket is mentioned.
- If a vault project exists, compare repo `PROGRESS.md` with Dev Vault `_project.md`, PM project record, PM task, and Dev kanban item.
- If a matching kanban task exists, ensure its status matches the active repo feature before planning/building.
- Use `grill-me` for missing critical context.
- Produce compact context for `plan` or `build`.

Keep context short and actionable.

## Clock-in rules

- WIP = 1: identify exactly one active feature/task before implementation.
- If repo, vault progress, and kanban disagree, record the mismatch in context and choose the safest non-destructive next step.
- If `AGENTS.md` or state files are missing and the user asks to improve the harness, use `write-agents-md`.
- Do not create or bulk-update vault files without confirmation; a normal update to an existing project progress note can be recommended for wrap-up.
