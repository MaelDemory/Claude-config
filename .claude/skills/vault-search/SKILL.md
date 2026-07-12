---
name: vault-search
description: Vault-search, Obsidian search, memory lookup, or project note lookup. Use to search the configured ObsidianMemory supervault and route to Dev, Research, Content, Investment, PM, or legacy vault context.
---
# Vault Search

## Configured vault paths

- Supervault root: `~/Documents/ObsidianMemory`
- Routing/indexes: `~/Documents/ObsidianMemory/00-Routing/`
- Dev Vault: `~/Documents/ObsidianMemory/Dev Vault/`
- Research Vault: `~/Documents/ObsidianMemory/Research Vault/`
- Content Vault: `~/Documents/ObsidianMemory/Content Vault/`
- Investment Vault: `~/Documents/ObsidianMemory/Investment Vault/`
- PM: `~/Documents/ObsidianMemory/PM/`
- Legacy life/business vault: `~/Documents/ObsidianLegacy`

Prefer indexes before broad search:
- `~/Documents/ObsidianMemory/README.md`
- `~/Documents/ObsidianMemory/00-Routing/index.md`
- `~/Documents/ObsidianMemory/00-Routing/vault-router.md`
- `~/Documents/ObsidianMemory/00-Routing/vault-registry.md`
- domain `_index.md` files

## Required vault search template

```markdown
## Query
- <user/task query>

## Vault scope
- Root: `~/Documents/ObsidianMemory`
- Domains searched: <Dev|Research|Content|Investment|PM|Legacy>
- Indexes checked: `<path>` / none

## Matches
| Note | Relevance | Evidence |
|---|---|---|
| `<path>` | <why it matters> | <quote/fact> |

## Answer / routing
- <what the search implies>
- Recommended destination for new notes: `<path>`

## Unknowns
- <missing vault path, stale index, no match, etc.>
```

Rules:
- Use exact paths.
- Search legacy ObsidianHugo only when history, personal/business context, or migration sources matter.
- If indexes are stale, report that explicitly and recommend an index update.
