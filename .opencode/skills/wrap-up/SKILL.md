---
name: wrap-up
description: Wrap-up, implementation summary, or final handoff. Use after build/test/review to explain what changed and what remains.
---
# Wrap-up

## Required final summary template

```markdown
## Summary
- <what was done>

## Files changed
- `<path>` — <purpose of change>

## Commands run
- `<command>` — <result and what it proved>

## State updates
- Repo progress: `PROGRESS.md` updated / not present / skipped — <why>
- Feature list: `feature_list.json` updated / not present / skipped — <why>
- Vault progress: ObsidianMemory Dev Vault/PM records updated / not configured / skipped — <why>
- Kanban task: <path/status updated> / none matched / skipped — <why>

## Failures or remaining risks
- <failure/risk or `None`>

## Follow-ups
- <optional next action or `None`>

## Confidence
- low / medium / high
```

Mention if docs/index/memory/progress/kanban/commit/PR were skipped or require explicit user request.

## Clock-out rules

- For implementation work, require build/test/review results before final handoff.
- A task is not complete unless verification evidence is reported.
- When a repo harness exists, record final state in `PROGRESS.md` and `feature_list.json` or explain why not.
- When a vault project/kanban task exists, keep vault progress and kanban status aligned with repo state or list the mismatch as a risk.
- Do not commit, push, or create PRs unless the user explicitly requested it.
