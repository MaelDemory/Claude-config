---
name: grill-me
description: Interviews the user one blocking question at a time to clarify or stress-test requirements. Use when a request is vague, when choices would lead to opposite implementations, when key constraints are missing, or before planning a new project.
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
