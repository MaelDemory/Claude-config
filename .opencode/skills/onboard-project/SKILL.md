---
name: onboard-project
description: Onboard-project, existing codebase onboarding, or create vault project from current repo. Use before cartography/indexing an existing repo into ObsidianMemory Dev Vault and PM.
---
# Onboard Project

## Configured vault paths

- Supervault root: `/Users/hugo/Documents/ObsidianMemory`
- Dev/code project memory: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project-slug>/`
- PM project record: `/Users/hugo/Documents/ObsidianMemory/PM/Projects/<project-slug>.md`
- PM task records: `/Users/hugo/Documents/ObsidianMemory/PM/Tasks/`
- Legacy life/business vault: `/Users/hugo/Documents/ObsidianHugo`

For existing codebases, default to Dev Vault project memory plus a PM project record. Ask for confirmation before creating a new vault project folder or making bulk vault writes, deletes, renames, or cross-vault migrations.

## Required onboarding report template

```markdown
# Onboard Project — <repo/project>

## Purpose
- <what the project appears to do>

## Stack and commands
- Runtime/framework: <detected evidence>
- Install/build/test commands: `<command>` — <source>

## Agent harness state
- Agent guide: `AGENTS.md` / `.opencode/AGENTS.md` / missing
- Progress: `PROGRESS.md` / missing
- Decisions: `DECISIONS.md` / missing
- Feature list: `feature_list.json` / missing
- Recommended harness update: <none or use `write-agents-md`>

## Directory map
- `<path>` — <responsibility>

## Docs/tests/config found
- `<path>` — <why relevant>

## Cartography outputs
- `<path>` — <created/updated doc>

## ObsidianMemory updates
- Dev project: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project-slug>/_project.md` / none
- PM project: `/Users/hugo/Documents/ObsidianMemory/PM/Projects/<project-slug>.md` / none
- Kanban: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project-slug>/kanban.md` / none

## Repo/vault/kanban alignment
- Repo progress: `PROGRESS.md` / none
- Feature list: `feature_list.json` / none
- Dev Vault project: `<path>` / none
- Matching PM task: `/Users/hugo/Documents/ObsidianMemory/PM/Tasks/<task>.md` / none
- Matching Dev kanban item: `<project>/kanban.md#<task>` / none
- Alignment notes: <repo/vault/kanban state agreement or mismatch>

## Unknowns / next actions
- <missing context or recommended next task>
```

## Onboarding steps

1. Read repo `AGENTS.md` / `.opencode/AGENTS.md` if present.
2. Identify stack, package manager, run/test/build commands, docs, and deployment hints from exact files.
3. Search ObsidianMemory before creating a new project:
   - `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/`
   - `/Users/hugo/Documents/ObsidianMemory/PM/Projects/`
   - `/Users/hugo/Documents/ObsidianMemory/00-Routing/vault-registry.md`
4. If no matching project exists, ask confirmation to create a Dev Vault project using `create-project`.
5. If a matching project exists, update only the relevant `_project.md`, `kanban.md`, or PM record with explicit confirmation when needed.
6. Recommend `write-agents-md` if the repo lacks a durable agent harness or verification commands.

Rules:
- Do not invent facts; cite exact files.
- Do not mark repo/vault/kanban alignment as done without evidence.
- Prefer linking existing notes over duplicating long documentation.
