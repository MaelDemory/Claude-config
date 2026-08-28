---
name: kanban-search
description: Kanban-search, find task, ticket lookup, or board search. Use by kanban/start-session workflows to locate relevant ObsidianMemory PM tasks and Dev Vault project kanban items.
---

Vault roots: `<vault-root>` and `<legacy-vault-root>` are configured in the global dev harness (`## Vault configuration` in `dev-harness.md`); defaults `~/Documents/ObsidianMemory` and `~/Documents/ObsidianLegacy`. Always quote vault paths in shell commands (folder names contain spaces).

# Kanban Search

## Configured kanban paths

- PM tasks: `<vault-root>/PM/Tasks/`
- PM projects: `<vault-root>/PM/Projects/`
- Dev project kanban: `<vault-root>/Dev Vault/projects/<project>/kanban.md`
- Dashboards: `<vault-root>/PM/Dashboards/`

Search PM tasks first. Then search Dev project `kanban.md` files when the task is repo/code-specific.

## Required kanban search template

```markdown
## Query
- <task/ticket/project being searched>

## Boards searched
- `<vault-root>/PM/Tasks/` — PM task records
- `<vault-root>/Dev Vault/projects/<project>/kanban.md` — Dev kanban / not searched

## Matching tasks
| Task | Status | Priority | Project | Relevance |
|---|---|---|---|---|
| <title/path> | <status> | <priority> | <project> | <why matched> |

## Context
- <important notes, blockers, links>

## Repo/vault state alignment
- Repo progress: `PROGRESS.md` / none found
- Feature list item: `feature_list.json:<id/status>` / none found
- PM task: `<vault-root>/PM/Tasks/<task>.md` / none found
- Dev Vault project: `<vault-root>/Dev Vault/projects/<project>/_project.md` / none found
- Dev kanban: `<vault-root>/Dev Vault/projects/<project>/kanban.md#<task>` / none found
- Alignment: <task agrees with repo/vault state, mismatch, or unknown>

## Suggested next action
- <plan/build/update/create task>
```

If task status conflicts with repo `PROGRESS.md` or `feature_list.json`, report the mismatch explicitly and do not mark the task done without verification evidence.
