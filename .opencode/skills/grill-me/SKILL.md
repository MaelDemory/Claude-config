---
name: grill-me
description: Grill me, clarify idea, interview user, or stress-test vague requirements. Use when more information is needed before planning or building.
---
# Grill Me

Ask one question at a time.

Use when:
- The task is vague.
- Multiple choices would lead to opposite implementations.
- The user likely omitted important constraints.
- A plan/design needs stress-testing.

## Required question template

```markdown
## Question <n>
- <single blocking question>

## Why it matters
- <risk avoided or branch resolved>

## Recommended answer
- <agent's recommended choice and why>

## Options
- A: <choice>
- B: <choice>
```

For each question, provide a recommended answer. If the codebase can answer it, inspect the code instead of asking.
