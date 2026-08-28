---
name: create-project
description: Create-project, new project vault setup, or project folder template. Use by the vault agent to create a project inside ObsidianMemory using Dev Vault, PM, and domain vault routing.
---

Vault roots: `<vault-root>` and `<legacy-vault-root>` are configured in the global dev harness (`## Vault configuration` in `dev-harness.md`); defaults `~/Documents/ObsidianMemory` and `~/Documents/ObsidianLegacy`. Always quote vault paths in shell commands (folder names contain spaces).

# Create Project

## Configured vault paths

- Supervault root: `<vault-root>`
- Dev/code project memory: `<vault-root>/Dev Vault/projects/<project-slug>/`
- Project Manager records: `<vault-root>/PM/Projects/<project-slug>.md`
- Project Manager tasks: `<vault-root>/PM/Tasks/`
- Research projects: `<vault-root>/Research Vault/projects/<project-slug>/`
- Content projects: `<vault-root>/Content Vault/projects/<project-slug>/`
- Investment projects: `<vault-root>/Investment Vault/projects/<project-slug>/`

Ask for confirmation before creating a new project folder, and before any bulk vault writes, deletes, renames, moves, or cross-vault migrations.

## Routing rule

- Code/repo/software project → create Dev Vault project + PM project record.
- Research-only project → create Research Vault project + PM project record.
- Content/publication project → create Content Vault project + PM project record.
- Investment research project → create Investment Vault project + PM project record.
- Unsure → create only a PM project record first, then ask before creating area folders.

## Required Dev Vault project structure

For code/repo/software projects, create:

```text
<vault-root>/Dev Vault/projects/<project-slug>/
├── _project.md
├── kanban.md
├── versions.md
├── architecture/adr/
├── changelog/
├── context/references/
├── learnings/
└── scratch/
```

Also create/update:

```text
<vault-root>/PM/Projects/<project-slug>.md
```

## Required `_project.md` template

```markdown
---
type: project
status: active
priority: medium
area: dev
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
repo: <path or URL>
tags: [project]
---

# <Project name>

## Overview
- <what the project does>

## Goal
- <target outcome>

## Scope
- In: <included work>
- Out: <non-goals>

## Stack
- <runtime/framework/services>

## Key links
- Repo: `<path or URL>`
- PM record: `<vault-root>/PM/Projects/<project-slug>.md`
- Kanban: `kanban.md`
- Versions: `versions.md`

## Success criteria
- <observable result>
```

## Required `kanban.md` template

```markdown
---
type: kanban
project: <Project name>
status: active
area: dev
updated: <YYYY-MM-DD>
tags: [kanban]
---

# <Project name> — Kanban

## Backlog
- [ ] <task> #feature

## In Progress

## Blocked

## Done
```

## Required `versions.md` template

```markdown
---
type: versions
project: <Project name>
area: dev
updated: <YYYY-MM-DD>
tags: [versions]
---

# <Project name> — Version History

| Version | Date | Summary |
| --- | --- | --- |
| v0.0.0 | <YYYY-MM-DD> | Project created in ObsidianMemory. |
```

## Required PM project record

Use `<vault-root>/templates/pm-project.md` if it exists; otherwise use this minimum:

```markdown
---
type: project
status: active
priority: medium
area: <dev|research|content|investment|life>
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
start: <YYYY-MM-DD>
due:
owner: <owner>
tags: [pm, project]
---

# <Project name>

## Purpose
- <why this project exists>

## Outcome
- <definition of done>

## Source folder
- `<domain-vault-path>`

## Tasks
```dataview
TABLE status, priority, due
FROM "PM/Tasks"
WHERE project = this.file.name OR contains(project, this.file.link)
SORT due ASC, priority ASC
```
```

## Required creation report

```markdown
## Project created
- Project: <name>
- Area: <dev|research|content|investment|life>
- Folder: `<path>`
- PM record: `<path>`
- Kanban: `<path or none>`

## Next steps
- <single next step>
```
