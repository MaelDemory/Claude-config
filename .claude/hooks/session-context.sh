#!/bin/bash
# SessionStart hook — injects a compact repo "clock-in" into the session context
# so Claude starts with the project state without the user asking for it.
#
# Parameters
#   stdin  SessionStart JSON payload (ignored; the hook runs in the project cwd).
# What it does
#   When the cwd is a git repo, prints branch, short status, last commits, open
#   PLAN-*.md files and the project's lessons.md (max 150 lines, with a nudge to
#   consolidate beyond that). Prints nothing outside a git repo. Never fails.
# Output
#   Plain text on stdout (added to Claude's context); always exit 0.

cat >/dev/null
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0

echo "## Repo clock-in (auto, SessionStart hook)"
echo "- Repo: $(basename "$root") — branch \`$(git branch --show-current 2>/dev/null || echo detached)\`"

changes=$(git status --short 2>/dev/null | head -15)
if [ -n "$changes" ]; then
  echo "- Uncommitted changes (max 15):"
  printf '%s\n' "$changes" | sed 's/^/    /'
else
  echo "- Working tree clean"
fi

echo "- Last commits:"
git log --oneline -3 2>/dev/null | sed 's/^/    /'

plans=$(ls PLAN-*.md 2>/dev/null | tr '\n' ' ')
[ -n "$plans" ] && echo "- Open plans: $plans"

if [ -f lessons.md ]; then
  echo
  echo "## lessons.md (project rules — follow them; add a rule after any correction)"
  head -150 lessons.md
  [ "$(wc -l <lessons.md)" -gt 150 ] && echo "(lessons.md > 150 lines: consolidate it — merge duplicates, drop obsolete rules)"
else
  echo "- No lessons.md yet: create it at the repo root on the first correction or mistake worth remembering."
fi
exit 0
