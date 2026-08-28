---
name: memory-write
description: Memory-write, save learning, coding advice, decision, or reusable project knowledge. Use to write durable notes into the configured ObsidianMemory vaults.
---

Vault roots: `<vault-root>` and `<legacy-vault-root>` are configured in the global dev harness (`## Vault configuration` in `dev-harness.md`); defaults `~/Documents/ObsidianMemory` and `~/Documents/ObsidianLegacy`. Always quote vault paths in shell commands (folder names contain spaces).

# Memory Write

## Configured vault paths

- Supervault root: `<vault-root>`
- Dev global memory: `<vault-root>/Dev Vault/global/`
- Dev project memory: `<vault-root>/Dev Vault/projects/<project-slug>/`
- Research memory: `<vault-root>/Research Vault/`
- Content memory: `<vault-root>/Content Vault/`
- Investment memory: `<vault-root>/Investment Vault/`
- PM/task memory: `<vault-root>/PM/`

## Routing rules

Save only durable, reusable knowledge. Route by topic:

| Memory type | Destination |
| --- | --- |
| Coding gotcha / implementation learning | `Dev Vault/global/learnings/<YYYY-MM-DD>-<slug>.md` or `Dev Vault/projects/<project>/learnings/<YYYY-MM-DD>-<slug>.md` |
| Architecture/product decision | `Dev Vault/global/decisions/<YYYY-MM-DD>-<slug>.md` or `Dev Vault/projects/<project>/architecture/adr/<NNN-slug>.md` |
| Reusable technical/domain knowledge | `Dev Vault/global/knowledge/<domain-or-pattern>/<slug>.md` |
| Project-specific handoff | `Dev Vault/projects/<project>/_project.md`, `kanban.md`, `versions.md`, or `scratch/` depending on durability |
| General research learning | `Research Vault/briefs/` or `Research Vault/topics/` |
| Content voice/process learning | `Content Vault/guides/` or `Content Vault/ideas/weekly-ideas.md` |
| Investment research learning | `Investment Vault/assets/`, `sectors/`, `memos/`, or `source-logs/` |
| Project/task tracking | `PM/Projects/` or `PM/Tasks/` |

Ask before writing broad, sensitive, or cross-vault notes.

## Required memory entry template

```markdown
---
type: memory
status: active
area: <dev|research|content|investment|pm>
project: <project or global>
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
tags: [memory]
---

# Memory — <short title>

## Learning / decision
- <durable knowledge>

## Evidence
- `<path>` — <proof/source>
- `<command>` — <what it proved, if applicable>

## When to reuse
- <trigger for future agents>

## Do not apply when
- <constraints or exceptions>

## Links
- <related notes/projects/tasks>
```

Rules:
- Save only durable knowledge, not every task detail.
- Evidence is required: path, command, source, or explicit user statement.
- Prefer updating an existing memory over creating duplicates.
- Use exact paths in the final report.
