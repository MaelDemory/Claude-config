---
name: commit
description: Inspects status and diffs, then writes and creates a git commit using the required <type>(<scope>) nomenclature. Use only when the user explicitly requests a commit, via the github agent; never commit on your own initiative.
---
# Commit

Use only when the user explicitly requests a commit.

Before committing:
- Inspect `git status`.
- Inspect `git diff` and staged diff.
- Inspect recent commit style.
- Stage only intended files.

## Commit nomenclature

Use this subject format unless the repository has a clear different convention:

```text
<type>(<scope>): <imperative summary>
```

Allowed types:
- `feat` — user-visible feature
- `fix` — bug fix
- `refactor` — behavior-preserving code restructuring
- `docs` — documentation only
- `test` — tests only
- `chore` — maintenance/config/tooling
- `perf` — performance improvement
- `build` — build/dependency changes
- `ci` — CI workflow changes

Optional body template:

```text
Why:
- <reason for change>

Verification:
- <commands run and result>
```

Never commit secrets, unrelated files, or unverified broad rewrites.
