---
name: create-project
description: Create-project, new project vault setup, or project folder template. Use by the vault agent to create a project inside ObsidianMemory using Dev Vault, PM, and domain vault routing.
---
# Create Project

## Configured vault paths

- Supervault root: `/Users/hugo/Documents/ObsidianMemory`
- Dev/code project memory: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project-slug>/`
- Project Manager records: `/Users/hugo/Documents/ObsidianMemory/PM/Projects/<project-slug>.md`
- Project Manager tasks: `/Users/hugo/Documents/ObsidianMemory/PM/Tasks/`
- Research projects: `/Users/hugo/Documents/ObsidianMemory/Research Vault/projects/<project-slug>/`
- Content projects: `/Users/hugo/Documents/ObsidianMemory/Content Vault/projects/<project-slug>/`
- Investment projects: `/Users/hugo/Documents/ObsidianMemory/Investment Vault/projects/<project-slug>/`

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
/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project-slug>/
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
/Users/hugo/Documents/ObsidianMemory/PM/Projects/<project-slug>.md
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
- PM record: `/Users/hugo/Documents/ObsidianMemory/PM/Projects/<project-slug>.md`
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

Use `/Users/hugo/Documents/ObsidianMemory/templates/pm-project.md` where possible, or this minimum:

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
owner: Hugo
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
