---
name: wrap-up
description: Produces the final handoff (summary, files changed, commands and evidence, lessons learned, risks). Use at the end of any build, test, and review chain or meaningful task, before the final response.
when_to_use: "Exemples : « résume ce que tu as fait », « fais le bilan », « wrap up », fin de tâche."
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

## Lessons
- `lessons.md`: <rule added/updated> / none — <why>

## Failures or remaining risks
- <failure/risk or `None`>

## Follow-ups
- <optional next action or `None`>

## Confidence
- low / medium / high
```

Mention if commit/PR were skipped or require explicit user request.

## Clock-out rules

- For implementation work, require build/test/review results before final handoff.
- A task is not complete unless verification evidence is reported.
- If the user corrected you or a mistake was found during the task, add the rule to `lessons.md` before handing off.
- Do not commit, push, or create PRs unless the user explicitly requested it.
