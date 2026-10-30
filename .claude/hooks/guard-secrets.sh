#!/bin/bash
# PreToolUse hook (Bash matcher) — blocks shell commands that would read secret
# files. Complements the Read() deny rules, which do not cover `cat .env` & co.
#
# Parameters
#   stdin  PreToolUse JSON payload ({ tool_input: { command } }).
# What it does
#   Blocks the command when it references .env files (except .env.example /
#   .env.sample / .env.template), private keys (*.pem, id_rsa, id_ed25519) or a
#   secrets/ directory. Passes everything else through. Requires jq; without
#   it, the hook does nothing.
# Output
#   exit 2 + reason on stderr (shown to Claude) when blocked; exit 0 otherwise.

input=$(cat)
command -v jq >/dev/null 2>&1 || exit 0
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
[ -z "$cmd" ] && exit 0

cleaned=$(sed -E 's/\.env\.(example|sample|template)//g' <<<"$cmd")
if grep -qE '(^|[^A-Za-z0-9_])\.env([^A-Za-z0-9_]|$)|\.env\.[A-Za-z0-9_]+|\.pem([^A-Za-z0-9_]|$)|id_rsa|id_ed25519|(^|[ /"'\''])secrets/' <<<"$cleaned"; then
  echo "Blocked by guard-secrets hook: the command touches a secret file (.env, key, secrets/). Ask the user if this is really needed." >&2
  exit 2
fi
exit 0
