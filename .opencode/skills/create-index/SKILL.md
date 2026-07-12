---
name: create-index
description: Create index, routing index, repo index, or vault index. Use to make compact navigation maps from documentation and cartography.
---
# Create Index

## Required index template

```markdown
# Index — <scope>

## Purpose
- What this index routes.

## Fast routes
| Need / question | Go to | Why |
|---|---|---|
| <task> | `<path>` | <reason> |

## Core docs
- `<path>` — <topic>

## Core code areas
- `<path>` — <responsibility>

## Vault links
- `/Users/hugo/Documents/ObsidianMemory/...` — <topic>

## Maintenance
- Last updated: <date>
- Update when: <trigger>
```

Rules:
- Keep entries one line when possible.
- Prefer links and exact paths over summaries.
- Do not duplicate full docs.
- Ask for confirmation before bulk vault writes, deletes, renames, or cross-vault changes.
