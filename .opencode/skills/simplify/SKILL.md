---
name: simplify
description: Simplify recently modified code, preserve behavior, reduce nesting/duplication, improve naming, or refine React/server code. Use after review and before final verification.
---
# Simplify

Use this as a targeted code clarity pass. It refines recently modified code while preserving functionality, contracts, and project conventions.

## Scope
- Focus on recently modified files/functions from the current task.
- Prefer surgical improvements over broad refactors.
- Preserve public APIs, behavior, data migrations, tests, and styling contracts.
- Do not introduce new features, new dependencies, or architectural rewrites.
- If a simplification would change behavior, skip it and report why.

## Required simplify workflow
1. Identify changed code
   - Use the task diff, changed files list, or implementation summary.
   - Prioritize the smallest functions/components touched by the current work.
2. Establish behavior boundaries
   - Note public inputs/outputs, side effects, errors, UI states, and tests that must remain unchanged.
3. Simplify for clarity
   - Reduce nesting and early-return when clearer.
   - Remove redundant variables, branches, wrappers, and dead code introduced by the change.
   - Improve unclear names when safe and local.
   - Extract small helpers only when duplication or complexity justifies it.
   - Replace nested ternaries with clearer conditionals or lookup maps.
   - Prefer explicit returns for function declarations where it improves readability.
   - Follow ES module and framework conventions already present in the repo.
   - For React: split oversized components, avoid inline logic soup, keep props clear, preserve hooks rules.
4. Verify preservation
   - Run focused tests/lint/typecheck when practical.
   - If verification is unavailable, state what was checked manually.

## Simplification checklist
- Recently modified code only.
- Reduced nesting / flatter control flow.
- Removed duplicate or redundant logic.
- Improved naming without churn.
- No public contract changes.
- No feature additions.
- No large speculative abstractions.
- React/UI code still follows `frontend-design` and `DESIGN.md` if relevant.

## Required output template

```markdown
## Simplification scope
- Changed files reviewed: `<path>`
- Behavior boundaries: <what must not change>

## Simplifications applied
- `<path>` — <what changed and why simpler>

## Simplifications considered but skipped
- `<path>` — <why skipped, especially behavior/API risk>

## Behavior preservation
- `<command>` — <what it proved>
- Manual check: <if no command was run>

## Follow-up risk
- <risk or `None`>
```
