---
name: write-agents-md
description: AGENTS.md, agent harness, PROGRESS.md, DECISIONS.md, feature_list.json, or repo state files. Use when creating or updating a repository's agent-readable harness and vault progress mirror.
---
# Write AGENTS.md

Use this skill to make a repository readable and governable by agents using plain files. The goal is the smallest durable harness that answers a fresh session's questions without turning `AGENTS.md` into an encyclopedia.

## Harness principles

- The repository is the specification: if it is not in repo or vault state, it does not exist to future agents.
- `AGENTS.md` is a router, not a manual. Target 50–200 lines.
- Knowledge lives next to the code it constrains; link out from `AGENTS.md` instead of duplicating details.
- Verification is mandatory evidence, not a feeling.
- Work in progress limit is 1: one active feature/task until verified or explicitly blocked.
- Persistent state belongs in git-tracked files and, when a vault project exists, linked to ObsidianMemory Dev Vault and PM records.
- Kanban and repo state must agree when a matching task exists.
- Do not commit unless the user explicitly asks.

## Required repo harness files

Create or update these files when useful for the project:

```text
<repo>/AGENTS.md                 # short landing page/router
<repo>/PROGRESS.md               # current state and next steps
<repo>/DECISIONS.md              # durable decisions and constraints
<repo>/feature_list.json         # executable task primitive, optional for tiny projects
<repo>/SPRINT-CONTRACT.md        # scope/rubric for non-trivial sessions, optional
<repo>/QUALITY.md                # periodic cleanup/drift notes, optional
```

Use `.opencode/AGENTS.md` only for project-specific opencode instructions when the repo already has another root `AGENTS.md` convention.

## Required `AGENTS.md` template

```markdown
# <Project name> Agent Guide

## Project overview
- <one-paragraph purpose and main user/system outcome>

## Stack and versions
- Runtime: <version source>
- Package manager: <version/source>
- Frameworks/services: <versions/source>

## First commands
- Setup: `<command>` — <when to run>
- Run: `<command>` — <what starts>
- Test: `<command>` — <default focused check>
- Full check: `<command>` — <lint/type/test/build gate>

## Hard constraints
- <MUST/MUST NOT rule> — Why: <reason>. Delete when: <expiry condition or `never while constraint holds`>.

## Clock-in
1. Read `PROGRESS.md`.
2. Read `DECISIONS.md`.
3. If present, read `feature_list.json` and pick exactly one active item.
4. If a vault project/kanban task is linked, verify repo state matches it.
5. Confirm the relevant verification command before editing.

## Work rules
- WIP = 1: work on exactly one feature/task at a time.
- No drive-by refactors or unrelated cleanup while the active task is unfinished.
- A task is complete only when its verification passes and evidence is recorded.
- Do not commit, push, or create PRs unless explicitly requested.

## Definition of done
1. Static checks pass: <lint/type command or N/A>.
2. Runtime checks pass: <unit/integration/start command or N/A>.
3. System check passes for cross-component changes: <E2E/manual command or N/A>.
4. `PROGRESS.md` and `feature_list.json` evidence are updated.
5. Matching vault kanban/progress is updated or a follow-up notes why not.

## Clock-out
1. Run the relevant verification command and record the result.
2. Update `PROGRESS.md` with done/in-progress/blocked/next steps.
3. Update `feature_list.json` evidence/status if present.
4. Mirror/link progress to `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/` and `/Users/hugo/Documents/ObsidianMemory/PM/Projects/<project>.md` when configured.
5. Update the matching kanban task status when one exists.

## Where to look
- Architecture: `<path>` — <what it answers>
- API/domain rules: `<path>` — <what it answers>
- UI/design: `<path>` — <what it answers>
- Operations/deploy: `<path>` — <what it answers>
- Vault project: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/_project.md` — <if configured>
- Kanban: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/kanban.md` — <if configured>
- PM project: `/Users/hugo/Documents/ObsidianMemory/PM/Projects/<project>.md` — <if configured>
```

## Required `PROGRESS.md` template

```markdown
# Project Progress

## Current state
- Date: <YYYY-MM-DD>
- Latest commit: <hash and subject, or `not checked`>
- Active task: <feature id/title or kanban task path>
- Kanban match: <vault task path/status or `none`>
- Vault mirror: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/_project.md` + PM project/task records / not configured

## Verification status
- Full check: `<command>` — <pass/fail/not run> — <evidence/date>
- Focused check: `<command>` — <pass/fail/not run> — <evidence/date>

## Done
- <completed work with evidence path/command>

## In progress
- <single active item, percent optional, blocker optional>

## Known issues / blockers
- <issue, owner/next diagnostic step>

## Next steps
1. <specific action that a fresh session can execute>
2. <specific action>
```

## Required `DECISIONS.md` template

```markdown
# Design Decisions

## <YYYY-MM-DD>: <decision title>
- Decision: <chosen approach>
- Reason: <why this was chosen>
- Rejected: <alternative> — <why rejected>
- Constraint: <live invariant future agents must preserve>
- Revisit when: <condition/date/event>
- Evidence: `<path or command>` — <proof/source>
```

## Required `feature_list.json` shape

```json
{
  "features": [
    {
      "id": "feature-001",
      "title": "<short title>",
      "user_visible_behavior": "<end-to-end behavior>",
      "status": "not_started",
      "kanban_task": "/Users/hugo/Documents/ObsidianMemory/PM/Tasks/<task or none>.md",
      "verification": [
        "<exact command or manual check>",
        "<expected observable result>"
      ],
      "evidence": []
    }
  ]
}
```

Allowed `status` values: `not_started`, `in_progress`, `blocked`, `passing`.

Rules:
- Calibrate each feature to roughly one session of work.
- Do not set status to `passing` without verification evidence.
- If a kanban task exists, `kanban_task` must point to it; otherwise use `none`.

## Required vault progress mirror

When the project has a vault folder, mirror repo progress to:

```text
/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/_project.md
/Users/hugo/Documents/ObsidianMemory/PM/Projects/<project>.md
```

Use this template:

```markdown
# Progress Mirror — <Project>

## Repo state
- Repo: `<path or URL>`
- Active task: <feature id/title>
- Latest verification: `<command>` — <pass/fail/not run> — <date>

## Kanban alignment
- PM task: `/Users/hugo/Documents/ObsidianMemory/PM/Tasks/<task>.md` / none
- Dev kanban: `/Users/hugo/Documents/ObsidianMemory/Dev Vault/projects/<project>/kanban.md#<task>` / none
- Status: <backlog|ready|in-progress|blocked|done>
- Repo feature: `<feature_list.json:id>` / none

## Session handoff
- Done: <summary>
- Blocked: <blocker or none>
- Next: <single next step>

## Evidence
- `<repo path>` — <what changed/proves state>
- `<command>` — <what it proved>
```

Ask before creating the vault project or doing bulk vault writes. A single update to an existing Dev Vault project or PM record is normal session state, but still mention it in wrap-up.

## Kanban alignment rules

- Search kanban before creating a new task when the user references a project/task/ticket.
- If a matching kanban task exists, link it in `PROGRESS.md` and `feature_list.json`.
- Status mapping:
  - `not_started` → `ready` or `backlog`
  - `in_progress` → `in-progress`
  - `blocked` → `blocked`
  - `passing` → `done` only after verification evidence is recorded
- If repo and kanban disagree, do not silently pick one. Record the mismatch in `PROGRESS.md` and ask or choose the safest non-destructive next step.

## Optional `SPRINT-CONTRACT.md` template

```markdown
# Sprint Contract — <task>

## Scope
- In: <included>
- Out: <explicit exclusions>

## Acceptance criteria
- <observable result>

## Verification standard
- `<command/manual check>` — <what it proves>

## Rubric
| Dimension | Pass standard | Evidence |
|---|---|---|
| Behavior | <standard> | <where captured> |
| Quality | <standard> | <where captured> |
| UX/accessibility | <standard or N/A> | <where captured> |
```

## Optional `QUALITY.md` template

```markdown
# Quality Log

## Current score
- Overall: <green/yellow/red>
- Main risks: <short list>

## Cleanup candidates
- `<path>` — <issue> — <safe next cleanup>

## Flaky or weak checks
- `<command/test>` — <symptom> — <next action>

## Last sweep
- Date: <YYYY-MM-DD>
- Evidence: `<command/path>`
```

## Editing rules

- Preserve existing project-specific rules unless they are stale and the evidence is clear.
- Add `Why` and `Delete when` to every new hard constraint.
- Prefer exact paths and commands over prose.
- Do not duplicate type definitions, config explanations, or generated API docs.
- Keep volatile state (`PROGRESS.md`, kanban status, evidence) out of the top of `AGENTS.md` so the stable router stays cache-friendly.
