---
name: vault-search
description: Vault-search, Obsidian search, memory lookup, or project note lookup. Use to search the configured ObsidianMemory supervault and route to Dev, Research, Content, Investment, PM, or legacy vault context.
---

Vault roots: `<vault-root>` and `<legacy-vault-root>` are configured in the global dev harness (`## Vault configuration` in `dev-harness.md`); defaults `~/Documents/ObsidianMemory` and `~/Documents/ObsidianLegacy`. Always quote vault paths in shell commands (folder names contain spaces).

# Vault Search

## Configured vault paths

- Supervault root: `<vault-root>`
- Routing/indexes: `<vault-root>/00-Routing/`
- Dev Vault: `<vault-root>/Dev Vault/`
- Research Vault: `<vault-root>/Research Vault/`
- Content Vault: `<vault-root>/Content Vault/`
- Investment Vault: `<vault-root>/Investment Vault/`
- PM: `<vault-root>/PM/`
- Legacy life/business vault: `<legacy-vault-root>`

Prefer indexes before broad search:
- `<vault-root>/README.md`
- `<vault-root>/00-Routing/index.md`
- `<vault-root>/00-Routing/vault-router.md`
- `<vault-root>/00-Routing/vault-registry.md`
- domain `_index.md` files

## Required vault search template

```markdown
## Query
- <user/task query>

## Vault scope
- Root: `<vault-root>`
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
- Search the legacy vault (<legacy-vault-root>) only when history, personal/business context, or migration sources matter.
- If indexes are stale, report that explicitly and recommend an index update.
