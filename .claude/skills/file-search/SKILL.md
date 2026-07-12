---
name: file-search
description: File search, code search, or exploration summary. Use to summarize focused repository/vault searches with exact paths and relevance.
---
# File Search

## Required search summary template

```markdown
## Search intent
- <question being answered>

## Scope searched
- `<path or glob>` — <why searched>

## Findings
| Path | Lines | Relevance |
|---|---:|---|
| `<path>` | <line/range> | <what it controls> |

## Facts vs assumptions
- Fact: <evidence-backed point>
- Assumption: <uncertain point>

## Next search
- <only if needed>
```

Rules:
- Do not scan whole workspaces unless needed.
- Prefer exact path + line references when available.
- Separate facts from assumptions.
