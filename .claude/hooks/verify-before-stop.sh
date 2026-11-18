#!/bin/bash
# Stop hook — refuses to end a turn that changed code without verifying it,
# enforcing the harness rule "done means verified by commands".
#
# Parameters
#   stdin  Stop JSON payload ({ transcript_path, stop_hook_active }).
# What it does
#   Reads the transcript since the last user prompt. If Claude edited a code
#   file (Edit, Write, MultiEdit, NotebookEdit on anything but .md/.txt/.rst)
#   and ran no Bash command after its last such edit, blocks the stop once and
#   asks for the relevant check. Never blocks twice in a row
#   (stop_hook_active). Requires python3; without it, the hook does nothing.
# Output
#   {"decision":"block","reason":...} on stdout when blocked; always exit 0.

command -v python3 >/dev/null 2>&1 || exit 0

python3 -c '
import json, sys
payload = json.load(sys.stdin)
if payload.get("stop_hook_active"):
    sys.exit(0)
entries = []
with open(payload.get("transcript_path") or "", encoding="utf-8") as f:
    for line in f:
        try:
            entries.append(json.loads(line))
        except ValueError:
            pass

def blocks(entry):
    content = (entry.get("message") or {}).get("content")
    return [{"type": "text"}] if isinstance(content, str) else (content or [])

# Start of the current turn: last user entry that is a prompt, not a tool result.
start = 0
for i, entry in enumerate(entries):
    if entry.get("type") == "user" and not any(b.get("type") == "tool_result" for b in blocks(entry)):
        start = i
edited = False
for entry in entries[start:]:
    if entry.get("type") != "assistant":
        continue
    for b in blocks(entry):
        if b.get("type") != "tool_use":
            continue
        name, args = b.get("name"), b.get("input") or {}
        if name in ("Edit", "Write", "MultiEdit", "NotebookEdit"):
            path = str(args.get("file_path") or args.get("notebook_path") or "")
            if not path.lower().endswith((".md", ".txt", ".rst")):
                edited = True
        elif name == "Bash":
            edited = False
if edited:
    print(json.dumps({"decision": "block", "reason":
        "Code was edited after the last verification command. Run the relevant check "
        "(tests, build, lint, script) before finishing, or state why it cannot be run."}))
' 2>/dev/null
exit 0
