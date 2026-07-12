---
name: create-pr
description: Create-pr, pull request, or PR body. Use by github agent when the user explicitly requests a PR.
---
# Create PR

Use only when the user explicitly requests a PR.

## PR title nomenclature

Use the same style as commits:

```text
<type>(<scope>): <imperative summary>
```

## Required PR body template

```markdown
## Summary
- <1-3 bullets describing the outcome>

## Changes
- <main implementation changes>
- <docs/config/test changes>

## Verification
- `<command>` — <what it proved>

## Risks / Rollback
- <known risks, migrations, feature flags, rollback path>

## Tests
- <tests passed, failed, or skipped>

## Links
- <issues, tasks, docs, screenshots for UI if relevant>
```

Before PR:
- Inspect status, diff, branch, and recent commits.
- Do not create PR if unrelated changes are present unless user confirms.
