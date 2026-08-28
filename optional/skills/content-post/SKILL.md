---
name: content-post
description: LinkedIn post, social post, short content draft, or post from notes. Use when the user asks to write/create a LinkedIn/social post using the Content Vault voice, evidence, and anti-AI-writing rules.
---

Vault roots: `<vault-root>` and `<legacy-vault-root>` are configured in the global dev harness (`## Vault configuration` in `dev-harness.md`); defaults `~/Documents/ObsidianMemory` and `~/Documents/ObsidianLegacy`. Always quote vault paths in shell commands (folder names contain spaces).

# Content Post

Create a LinkedIn/social post using the ObsidianMemory Content Vault workflow.

## Required paths

- Content root: `<vault-root>/Content Vault`
- Workflow: `<vault-root>/Content Vault/workflows/post.md`
- Humanization guide: `<vault-root>/Content Vault/guides/seo-humanize.md`
- Content pillars: `<vault-root>/Content Vault/guides/content-pillars.md`
- Positioning: `<vault-root>/Content Vault/guides/positioning.md`
- Output folder: `<vault-root>/Content Vault/linkedin/`
- Template: `<vault-root>/Content Vault/templates/linkedin-post.md`

## Workflow

1. Read the workflow and all required guides before drafting. If a required guide is missing, report "Content Vault guides not configured" with the missing paths and stop instead of improvising voice/positioning rules.
2. Search relevant vault context:
   - Content Vault for prior drafts and positioning.
   - Dev Vault for project evidence if technical.
   - `<legacy-vault-root>` only when legacy personal/business context is relevant.
3. Extract concrete proof: dates, numbers, failed attempts, decisions, outcomes, screenshots to mention, or source notes.
4. Draft a 150-300 word post with:
   - feed-safe hook in 1-2 lines
   - short paragraphs
   - one main message
   - process/friction, not only result
   - one CTA or none
5. Create a markdown note in the output folder unless the user only asks for text in chat.
6. Include writing notes: topic, main message, sources used, and metrics placeholders.

## Quality bar

- Apply every rule in `seo-humanize.md`.
- Do not invent metrics or claims.
- Do not use guru/corporate tone.
- Do not write generic AI thought leadership without concrete evidence.
