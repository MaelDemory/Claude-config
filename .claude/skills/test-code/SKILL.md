---
name: test-code
description: Test code, write tests, or validate implementation. Use when creating focused tests from the plan/spec rather than from implementation details.
---
# Test Code

Derive tests from expected behavior.

## Test design workflow

1. Identify the contract first.
   - Use the user request, `PLAN-*.md`, docs, public API/UI/CLI behavior, and existing tests.
   - Read implementation only as much as needed to locate entrypoints and conventions.
2. Pick high-signal cases.
   - Include a success path, at least one meaningful edge case, and one regression/failure mode when relevant.
   - Prefer assertions that would fail for superficial, hard-coded, or overly narrow implementations.
3. Match project conventions.
   - Reuse existing test helpers, fixtures, factories, mocks, and naming patterns.
   - Add minimal new helpers only when repetition or clarity justifies them.
4. Verify narrowly.
   - Run the focused test command first.
   - If focused verification is impossible, state the nearest available check and remaining risk.

## Required test plan template

```markdown
## Behavior under test
- <expected behavior from plan/spec>

## Entry point
- Public API/UI/CLI: `<path or command>`

## Test cases
| Case | Expected result | Failure mode caught |
|---|---|---|
| Success path | <expected> | <wrong implementation caught> |
| Edge case | <expected> | <wrong implementation caught> |

## Files changed
- `<test path>` — <coverage added>

## Verification command
- `<command>` — <what it proves>
```

Rules:
- Do not weaken assertions to fit implementation.
- Prefer black-box expectations.
- Keep test infrastructure minimal.

## Good vs bad tests

Good:
- Tests the public API/route/component output rather than private helper internals.
- Fails if validation, auth, persistence, error handling, or user-visible state is wrong.
- Names the bug/regression it prevents in the case description.
- Uses existing fixtures and mocks instead of inventing incompatible infrastructure.

Bad:
- Asserts implementation details that can change without changing behavior.
- Only covers the happy path after reading the implementation.
- Weakens or snapshots broad output just to make the test pass.
- Skips failing tests or changes expected behavior without plan/user evidence.

## Failure interpretation

When tests fail, classify the failure as:
- Product bug: implementation does not meet the expected contract.
- Test bug: test setup/assertion is wrong or too coupled.
- Environment issue: dependency, service, fixture, or command cannot run locally.
- Ambiguity: expected behavior is not specified clearly enough.
