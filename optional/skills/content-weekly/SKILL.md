---
name: content-weekly
description: Weekly content generation, content ideas from week, repurpose recent notes, or content calendar. Use when the user asks what to post from recent work or wants LinkedIn/article ideas from vault notes.
---

Vault roots: `<vault-root>` and `<legacy-vault-root>` are configured in the global dev harness (`## Vault configuration` in `dev-harness.md`); defaults `~/Documents/ObsidianMemory` and `~/Documents/ObsidianLegacy`. Always quote vault paths in shell commands (folder names contain spaces).

# Content Weekly

Generate content ideas and drafts from recent notes using the ObsidianMemory Content Vault workflow.

## Required paths

- Content root: `<vault-root>/Content Vault`
- Workflow: `<vault-root>/Content Vault/workflows/generate-content-from-week.md`
- Humanization guide: `<vault-root>/Content Vault/guides/seo-humanize.md`
- Content pillars: `<vault-root>/Content Vault/guides/content-pillars.md`
- Positioning: `<vault-root>/Content Vault/guides/positioning.md`
- Output backlog: `<vault-root>/Content Vault/ideas/weekly-ideas.md`

## Workflow

1. Read workflow, content pillars, positioning, and humanization guide. If a required guide is missing, report "Content Vault guides not configured" with the missing paths and stop instead of improvising voice/positioning rules.
2. Search recent notes from:
   - Content Vault drafts and idea backlog.
   - Dev Vault project changelogs, kanban, learnings, and decisions.
   - The legacy vault (<legacy-vault-root>) journals/reviews when relevant.
3. Extract 5-10 concrete moments from the week:
   - problem
   - decision
   - result
   - failed attempt
   - lesson
4. Produce:
   - 5-10 post ideas
   - 2 LinkedIn drafts
   - 1 Medium article outline
5. Append a dated section to the output backlog when the user wants persistence.

## Quality bar

- Every idea needs source context or `source needed`.
- Map each idea to a content pillar.
- Prefer real work over generic thought leadership.
- Do not invent what happened during the week.
