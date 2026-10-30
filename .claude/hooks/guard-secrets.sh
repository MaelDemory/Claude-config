#!/bin/bash
# PreToolUse hook (Bash matcher) — blocks shell commands that would read secret
# files. Complements the Read() deny rules, which do not cover `cat .env` & co.
#
# Parameters
#   stdin  PreToolUse JSON payload ({ tool_input: { command } }).
# What it does
#   Splits the command into shell words and blocks it when one word is a path
#   to a secret: a .env file (except .env.example / .env.sample /
#   .env.template), a private key (*.pem, id_rsa*, id_ed25519*) or anything
#   under a secrets/ directory. Words are checked as paths, so text that merely
#   mentions ".env" (a grep pattern, a PR body) passes. Requires python3;
#   without it, the hook does nothing.
# Output
#   exit 2 + reason on stderr (shown to Claude) when blocked; exit 0 otherwise.

command -v python3 >/dev/null 2>&1 || exit 0

python3 -c '
import json, re, shlex, sys

try:
    cmd = json.load(sys.stdin).get("tool_input", {}).get("command") or ""
except ValueError:
    sys.exit(0)

# Heredoc bodies are data, not arguments: drop them. Command substitutions
# become separate words.
cmd = re.sub(r"<<-?\s*([\x27\"]?)(\w+)\1([^\n]*)\n.*?\n\s*\2[ \t]*(?=\n|$)", r"\3", cmd, flags=re.S)
cmd = cmd.replace("$(", " ( ").replace("`", " ")
try:
    lexer = shlex.shlex(cmd, posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    words = list(lexer)
except ValueError:
    words = cmd.split()

def is_secret(word):
    for part in re.split(r"[=:@<>]", word):
        part = part.strip("\"'\'' ")
        if not part or " " in part:
            continue
        name = part.rstrip("/").rsplit("/", 1)[-1]
        if name == ".env" or (name.startswith(".env.") and name not in (".env.example", ".env.sample", ".env.template")):
            return True
        if name.endswith(".pem") or name.startswith(("id_rsa", "id_ed25519")):
            return True
        if re.search(r"(^|/)secrets/", part):
            return True
    return False

if any(is_secret(w) for w in words):
    print("Blocked by guard-secrets hook: the command touches a secret file (.env, key, secrets/). Ask the user if this is really needed.", file=sys.stderr)
    sys.exit(2)
'
