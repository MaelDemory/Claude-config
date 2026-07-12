---
name: comment
description: Comment code, explain functions, or add documentation comments. Use to make code understandable after implementation.
---
# Comment

Use comments only when they make code easier to maintain. Prefer clearer names and smaller functions before adding comments.

## Required comment nomenclature

Every function-level or module-level explanatory comment must use exactly these three sections, in this order:

```text
Parameters
- `<name>`: what the input represents, constraints, and units/shape when useful.

What it does
- Short explanation of the behavior, important side effects, and why the code exists.

Output
- Return value, thrown errors, mutations, emitted events, or external effects.
```

## Rules
- Explain why and contract, not obvious line-by-line behavior.
- Keep each section short; omit only if truly not applicable, using `None`.
- Update or remove stale comments when behavior changes.
- Do not add decorative comments, TODOs without owner/context, or comments that duplicate names.
