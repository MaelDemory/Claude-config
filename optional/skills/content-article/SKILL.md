---
name: content-article
description: Medium article, long-form article, essay, or article from notes. Use when the user asks to create/write a Medium-style article using Content Vault evidence, positioning, and humanization rules.
---

Vault roots: `<vault-root>` and `<legacy-vault-root>` are configured in the global dev harness (`## Vault configuration` in `dev-harness.md`); defaults `~/Documents/ObsidianMemory` and `~/Documents/ObsidianLegacy`. Always quote vault paths in shell commands (folder names contain spaces).

# Content Article

Create a Medium-style article draft using the ObsidianMemory Content Vault workflow.

## Required paths

- Content root: `<vault-root>/Content Vault`
- Workflow: `<vault-root>/Content Vault/workflows/article.md`
- Humanization guide: `<vault-root>/Content Vault/guides/seo-humanize.md`
- Content pillars: `<vault-root>/Content Vault/guides/content-pillars.md`
- Positioning: `<vault-root>/Content Vault/guides/positioning.md`
- Output folder: `<vault-root>/Content Vault/medium/`
- Template: `<vault-root>/Content Vault/templates/medium-article.md`

## Workflow

1. Read the workflow and all required guides first. If a required guide is missing, report "Content Vault guides not configured" with the missing paths and stop instead of improvising voice/positioning rules.
2. Research deeper than for a post:
   - Search Content Vault for related drafts.
   - Search Dev Vault for project chronology, decisions, failures, and measurable results.
   - Search the legacy vault (<legacy-vault-root>) when older article, journal, or project context matters.
   - Use web research only for necessary external context.
3. Extract timeline, decisions, pivots, numbers, failures, lessons, and personal angle.
4. If the direction is not already approved, propose and wait for validation on:
   - Title
   - Subtitle
   - Angle
   - Main message
   - 5-section structure
   - Medium tags
5. Draft 800-2000 words.
6. Create a markdown note in the output folder unless the user only asks for text in chat.
7. Include writing notes: angle, main message, sources used, image suggestions, and publication checklist.

## Quality bar

- Apply every rule in `seo-humanize.md`.
- First two sentences must work as Medium preview text.
- Use H2 sections, not a table of contents.
- End with a thought, question, or next step, not a recap.
- Do not invent claims, metrics, or external context.
