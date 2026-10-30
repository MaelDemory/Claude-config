---
name: review-code
description: Reviews code quality (logic, complexity, duplication, oversized files, wrong abstractions, type/error/security/accessibility risks). Use after any meaningful implementation, before simplify-code, tests, and the final response.
---
# Review Code

## Required review checklist
- Logical coherence
- Unnecessary complexity
- Duplicated code
- Files/functions growing too large
- Wrong abstraction level
- Reusable components/services ignored
- Type, error handling, security, and accessibility risks

## Required output template

```markdown
## Required fixes
- `<path>` — <fix and reason>

## Simplifications worth doing now
- `<path>` — <safe simplification>

## Deferred improvements
- <optional future work, not required now>

## Slop signals checked
- Oversized files: yes/no + details
- Duplication: yes/no + details
- Avoidable abstraction: yes/no + details

## Confidence
- low / medium / high
```
