---
name: implementation-review
description: Implementation review, final diff review, or logic check. Use to compare code changes against the original goal, plan, and verification output.
---
# Implementation Review

## Required inputs
- Original request
- Plan / `PLAN-*.md` / `TASK_CONTEXT.md`
- Files changed
- Diff summary
- Commands run and output

Checklist:
1. Scope: only intended files changed?
2. Correctness: behavior matches the plan?
3. Logic: implementation is coherent and not accidental?
4. Contracts: APIs/types/config/public behavior preserved?
5. Regression: likely breakages?
6. Verification: relevant checks run and passed?

## Required output template

```markdown
## Verdict
- pass / pass-with-risk / fail

## Changed files reviewed
- `<path>` — <review scope>

## Blocking issues
- <issue, exact path/line if possible, why it blocks>

## Minimal required fixes
- <smallest fix that resolves the issue>

## Verification summary
- `<command>` — <result and what it proved>

## Remaining risks
- <risk or `None`>

## Confidence
- low / medium / high
```
