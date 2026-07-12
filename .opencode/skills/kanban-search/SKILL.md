---
name: kanban-search
description: Kanban-search, find task, ticket lookup, or board search. Use by kanban/start-session workflows to locate relevant ObsidianMemory PM tasks and Dev Vault project kanban items.
---
# Kanban Search

## Configured kanban paths

- PM tasks: `/Users/hugo/Documents/ObsidianMemory/PM/Tasks/`
- PM projects: `/Users/hugo/Documents/ObsidianMemory/PM/Projects/`
- Dev project kanban: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/kanban.md`
- Dashboards: `/Users/hugo/Documents/ObsidianMemory/PM/Dashboards/`

Search PM tasks first. Then search Dev project `kanban.md` files when the task is repo/code-specific.

## Required kanban search template

```markdown
## Query
- <task/ticket/project being searched>

## Boards searched
- `/Users/hugo/Documents/ObsidianMemory/PM/Tasks/` — PM task records
- `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/kanban.md` — Dev kanban / not searched

## Matching tasks
| Task | Status | Priority | Project | Relevance |
|---|---|---|---|---|
| <title/path> | <status> | <priority> | <project> | <why matched> |

## Context
- <important notes, blockers, links>

## Repo/vault state alignment
- Repo progress: `PROGRESS.md` / none found
- Feature list item: `feature_list.json:<id/status>` / none found
- PM task: `/Users/hugo/Documents/ObsidianMemory/PM/Tasks/<task>.md` / none found
- Dev Vault project: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/_project.md` / none found
- Dev kanban: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/kanban.md#<task>` / none found
- Alignment: <task agrees with repo/vault state, mismatch, or unknown>

## Suggested next action
- <plan/build/update/create task>
```

If task status conflicts with repo `PROGRESS.md` or `feature_list.json`, report the mismatch explicitly and do not mark the task done without verification evidence.
