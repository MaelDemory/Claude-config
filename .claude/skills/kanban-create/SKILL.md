---
name: kanban-create
description: Kanban-create, create task, or write ticket. Use by kanban/vault workflows to create structured task records in ObsidianMemory PM and optionally link Dev Vault project kanban.
---

Vault roots: `<vault-root>` and `<legacy-vault-root>` are configured in the global dev harness (`## Vault configuration` in `dev-harness.md`); defaults `~/Documents/ObsidianMemory` and `~/Documents/ObsidianLegacy`. Always quote vault paths in shell commands (folder names contain spaces).

# Kanban Create

## Configured task paths

- PM tasks: `<vault-root>/PM/Tasks/<task-slug>.md`
- PM projects: `<vault-root>/PM/Projects/<project-slug>.md`
- Optional Dev kanban link: `<vault-root>/Dev Vault/projects/<project>/kanban.md#<task>`

Create one PM task note per durable task. Only also update Dev project `kanban.md` when the task is code/repo-specific and a matching Dev Vault project exists.

## Required task template

```markdown
---
type: task
status: todo
priority: <low|medium|high>
project: <project or inbox>
area: <dev|research|content|investment|life>
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
start:
due:
owner: <owner>
tags: [pm, task]
---

# <Task title>

## Idea
- <raw user idea/request>

## Goal
- <desired outcome>

## Scope
- In: <included work>
- Out: <non-goals>

## Implementation idea
- <initial approach, files, subagents>

## Acceptance criteria
- [ ] <observable result>

## Links / references
- `<path or URL>` — <why relevant>

## Repo/vault state alignment
- Repo: `<path or URL>` / none
- Progress: `PROGRESS.md` / none
- Feature: `feature_list.json:<id>` / none
- PM project: `<vault-root>/PM/Projects/<project>.md` / none
- Dev project: `<vault-root>/Dev Vault/projects/<project>/_project.md` / none
- Dev kanban: `<vault-root>/Dev Vault/projects/<project>/kanban.md#<task>` / none
```

Ask before bulk task creation. When creating a task for an existing repo feature, link the repo `PROGRESS.md`, `feature_list.json` item, PM task, and Dev kanban item when present.
