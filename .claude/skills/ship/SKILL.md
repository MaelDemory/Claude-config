---
name: ship
description: Delivers a feature or fix end to end without user hand-holding (clock-in, plan, build, review, test, wrap-up), scaled to the size of the change. Use when the user asks to build, implement, fix or ship something and expects a finished, verified result.
---
# Ship

Orchestrates the dev harness build chain from one request. The user should not have to invoke any other skill.

## Required workflow

1. Clock in
   - Use the SessionStart clock-in already in context (repo state and `lessons.md`).
   - Restate the goal as verifiable success criteria (a test or check that proves it).
2. Size the change (see `## Build chain` in the dev harness)
   - small / medium / large, with a one-line reason.
   - If the default branch is checked out and the change is medium/large, create a work branch: `git switch -c <type>/<short-name>`.
3. Clarify before coding, not after
   - Several real interpretations, or a simpler approach than asked: say so and ask (`grill-me`, one question) before writing code.
   - Minor unknowns a reasonable assumption covers: state the assumption and continue.
4. Plan (large only; medium when several files must stay coherent)
   - `planner` subagent → `create-plan` → `plan-contest` → revise until verdict is `pass`.
5. Build
   - Delegate to `frontend` / `backend` when it keeps the main context small; use `architecture` for structural decisions.
   - UI work: delegate to `frontend`, which picks the design skills and verifies in a browser (`webapp-testing`).
6. Verify
   - Run the project's checks (tests, lint, typecheck, build). Fix in scope up to two times.
7. Review (medium/large)
   - `review` subagent with `implementation-review`; pass it goal, plan path, changed files, `git diff` and check output.
   - Large: then `review-code` and `simplify-code` (or built-in `/code-review`, `/simplify`). Re-run checks after edits.
8. Test (medium/large)
   - `test` subagent with `test-code`, derived from the plan/spec. Run the focused test command.
9. Clock out
   - Add any lesson learned (user correction, mistake found) to `lessons.md`.
   - `wrap-up`, then the final response template from the dev harness.

## Required output template

```markdown
## Ship report
- Goal: <one line>
- Size: small / medium / large — <reason>
- Branch: `<branch>`
- Assumptions: <list or none>

## Chain executed
- Plan: done / skipped (<why>) — `<PLAN-*.md>`
- Build: <agents used>
- Checks: `<command>` — pass / fail
- Review: <verdict> / skipped (<why>)
- Tests: `<command>` — pass / fail / skipped (<why>)

## Remaining risks
- <risk or none>
```

Rules:
- Never skip a step silently: mark it skipped with a reason.
- Every changed line must trace to the request: no drive-by refactors or speculative abstractions.
- Do not push, open PRs, merge or publish without an explicit user request.
- Stop and report instead of looping when checks still fail after two fix attempts.
