---
name: create-plan
description: Create-plan, PLAN file, TASK_CONTEXT.md, implementation plan, or planning template. Use by the plan agent to write PLAN-*.md, maintain TASK_CONTEXT.md, and invoke plan-contest.
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

## State alignment
- Progress: `PROGRESS.md` — <active state or missing>
- Decisions: `DECISIONS.md` — <constraints affecting this plan or missing>
- Feature list: `feature_list.json` — <feature id/status or missing>
- Kanban: `/Users/hugo/Documents/ObsidianMemory/PM/Tasks/<task>.md` or Dev Vault `projects/<project>/kanban.md` — <task/status or none>

## Assumptions
- <assumption and impact if wrong>

## Proposed changes
- `<path or area>` — <planned edit>

## Implementation steps
1. <smallest safe step>
2. <next step>

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

## Required `TASK_CONTEXT.md` template

Create or update `TASK_CONTEXT.md` next to the project's durable state files (`PROGRESS.md`, `DECISIONS.md`, `feature_list.json`) when the task is non-trivial or should be handed to `build`.

Use this exact section structure:

```markdown
# Task Context

## Goal
<one concise paragraph describing the desired implementation outcome and scope boundaries>

## Files read
- `<path>`

## Assumptions
- <assumption or constraint the build agent must preserve>

## Files to change

### Update `<path>`

#### 1. <change area>
<specific build-ready instructions, constraints, schemas, formulas, examples, or sequencing notes>

## Files not to change
- `<path or area>`

## Acceptance criteria
- <observable behavior or artifact required for completion>

## Verification
- `<command>`
- <manual check if needed>

## Open questions
- <blocking or non-blocking question, or `None`>
```

Rules:
- `TASK_CONTEXT.md` is the active handoff file for `build`; keep it compact but complete enough that `build` does not need to rediscover the full task.
- Include every file already read that materially shaped the plan.
- Preserve explicit user constraints exactly, especially “do not change” areas, formulas, schemas, compatibility requirements, and verification commands.
- If there are multiple files to change, add one `### Update <path>` / `### Add <path>` / `### Remove <path>` subsection per file or area.
- Use nested numbered subsections under each file only when they clarify implementation sequencing.
- Keep open questions separated from assumptions; mark non-blocking questions as non-blocking.
- Do not include secrets, credentials, or unrelated repo history.

Rules:
- Save as `PLAN-<short-name>.md` when writing a plan file.
- Save/update `TASK_CONTEXT.md` when a durable build handoff is useful or when the user asks for TASK_CONTEXT integration.
- For non-trivial work, ask `plan-contest` to challenge it and revise.
- Plan one active feature/task at a time unless the user explicitly asks for a roadmap.
- If a matching kanban task exists, include how the plan will keep repo progress, vault progress, and kanban status aligned.

## Plan quality checklist

- Build-ready: a build agent can start without rediscovering the full codebase.
- Smallest viable scope: no unrelated cleanup, speculative architecture, or broad rewrites.
- Evidence-backed: context read lists exact paths and why they matter.
- Decision clarity: assumptions say what happens if they are wrong.
- Sequenced safely: risky migrations, public contract changes, and destructive edits are isolated and reversible where possible.
- Verification-specific: each check says what behavior or risk it proves, not just “run tests.”
- Handoff-ready: identifies which subagents/skills to use and when.
- Context-ready: `TASK_CONTEXT.md` captures exact files read, assumptions, files to change/not change, acceptance criteria, verification, and open questions.

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
