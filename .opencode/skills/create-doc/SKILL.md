---
name: create-doc
description: Create doc, documentation, repo docs, or vault docs. Use when writing concise project documentation inside the codebase and optionally ObsidianMemory.
---
# Create Doc

Write documentation that helps future agents navigate faster.

## Required documentation template

```markdown
# <Doc title>

## Purpose
- What this document helps future agents/humans do.

## When to use
- Questions or tasks this doc should answer.

## Context map
- `<path>` — why it matters.

## Workflow / behavior
- Step-by-step flow, lifecycle, or user-visible behavior.

## Decisions and constraints
- Important choices, trade-offs, invariants, and non-goals.

## Verification / maintenance
- Commands, checks, ownership, and when to update this doc.
```

Rules:
- Prefer exact paths and short sections.
- Do not duplicate indexes; link to them.
- If also writing to the vault, use `/Users/hugo/Documents/ObsidianMemory` and route to the relevant domain vault.
- Ask for confirmation before bulk vault writes, deletes, renames, or cross-vault changes.
