---
name: vault-search
description: Vault-search, Obsidian search, memory lookup, or project note lookup. Use to search the configured ObsidianMemory supervault and route to Dev, Research, Content, Investment, PM, or legacy vault context.
---
# Vault Search

## Configured vault paths

- Supervault root: `/Users/hugo/Documents/ObsidianMemory`
- Routing/indexes: `/Users/hugo/Documents/ObsidianMemory/00-Routing/`
- Dev Vault: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/`
- Research Vault: `/Users/hugo/Documents/ObsidianMemory/Research Vault/`
- Content Vault: `/Users/hugo/Documents/ObsidianMemory/Content Vault/`
- Investment Vault: `/Users/hugo/Documents/ObsidianMemory/Investment Vault/`
- PM: `/Users/hugo/Documents/ObsidianMemory/PM/`
- Legacy life/business vault: `/Users/hugo/Documents/ObsidianHugo`

Prefer indexes before broad search:
- `/Users/hugo/Documents/ObsidianMemory/README.md`
- `/Users/hugo/Documents/ObsidianMemory/00-Routing/index.md`
- `/Users/hugo/Documents/ObsidianMemory/00-Routing/vault-router.md`
- `/Users/hugo/Documents/ObsidianMemory/00-Routing/vault-registry.md`
- domain `_index.md` files

## Required vault search template

```markdown
## Query
- <user/task query>

## Vault scope
- Root: `/Users/hugo/Documents/ObsidianMemory`
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
