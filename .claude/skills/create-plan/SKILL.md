---
name: create-plan
description: Writes PLAN-*.md from the required template and sends the plan to plan-contest. Use when the planner subagent or main session plans non-trivial implementation work before building.
---

# Create Plan

## Required `PLAN-*.md` template

```markdown
# PLAN-<short-name>

## Goal
- <desired outcome>

## Success criteria
- <observable acceptance criteria>

## Context read
- `<path>` — <why it matters>

## Lessons applied
- `lessons.md` — <rules that constrain this plan, or none>

## Assumptions
- <assumption and impact if wrong>

## Proposed changes
- `<path or area>` — <planned edit>

## Implementation steps
1. <smallest safe step> → verify: <check>
2. <next step> → verify: <check>

## Subagents / skills
- `<agent or skill>` — <when to use>

## Verification
- `<command>` — <what it proves>

## Risks / rollback
- <risk and mitigation>

## Plan-contest feedback
- <challenge>
- <revision made>
```

Rules:
- Save as `PLAN-<short-name>.md` when writing a plan file.
- For non-trivial work, ask `plan-contest` to challenge it and revise.
- Plan one active feature/task at a time unless the user explicitly asks for a roadmap.
- Each implementation step ends with how it is verified (`step → verify: check`).

## Plan quality checklist

- Build-ready: a build agent can start without rediscovering the full codebase.
- Smallest viable scope: no unrelated cleanup, speculative architecture, or broad rewrites.
- Evidence-backed: context read lists exact paths and why they matter.
- Decision clarity: assumptions say what happens if they are wrong.
- Sequenced safely: risky migrations, public contract changes, and destructive edits are isolated and reversible where possible.
- Verification-specific: each check says what behavior or risk it proves, not just “run tests.”
- Handoff-ready: identifies which subagents/skills to use and when.
- Lesson-aware: rules from `lessons.md` that apply are listed and respected.

## Good vs bad plan entries

Good:
- Proposed change: `src/server/orders/createOrder.ts` — add idempotency validation before payment capture.
- Verification: `pnpm test src/server/orders/createOrder.test.ts` — proves duplicate checkout requests return the existing order without a second charge.
- Assumption: payment provider exposes idempotency keys; if false, build must add a local transaction guard instead.

Bad:
- Proposed change: “Update backend.”
- Verification: “Run tests.”
- Assumption: “Should be fine.”

## Anti-patterns

- Planning implementation details line-by-line before reading the real files.
- Creating a plan so large that it becomes a design document rather than a task spec.
- Skipping `plan-contest` for changes touching data, auth, payments, migrations, public APIs, or multi-module architecture.
- Asking the user questions that the codebase or docs can answer with a quick search.
