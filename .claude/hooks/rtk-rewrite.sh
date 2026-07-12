#!/bin/bash
# PreToolUse hook (Bash matcher) — rewrites commands through `rtk rewrite`
# for token savings. Port of the OpenCode rtk plugin (.opencode/plugins/rtk.ts).
# All rewrite logic lives in `rtk rewrite`; this script only delegates.
# Requires: rtk >= 0.23.0 in PATH. If rtk is missing or the rewrite fails,
# the command passes through unchanged (empty output, exit 0).

input=$(cat)

command -v rtk >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
[ -z "$cmd" ] && exit 0

rewritten=$(rtk rewrite "$cmd" 2>/dev/null)
[ -z "$rewritten" ] && exit 0
[ "$rewritten" = "$cmd" ] && exit 0

jq -n --arg cmd "$rewritten" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    updatedInput: { command: $cmd }
  }
}'
