#!/bin/bash
# Tests de non-régression du hook verify-before-stop.sh.
#
# Parameters
#   aucun (lancé par scripts/check.sh ou à la main).
# What it does
#   Construit des transcripts JSONL minimaux, les passe au hook et vérifie s'il
#   bloque (block) ou laisse finir (pass) : édition de code sans vérification
#   ensuite, édition suivie d'une commande Bash, édition de doc seule, édition
#   d'un tour précédent, second passage (stop_hook_active).
# Output
#   Une ligne ok/FAIL par cas ; code retour 1 si un cas échoue.

H="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.claude/hooks/verify-before-stop.sh"
TMP=$(mktemp -d)
# Git Bash : le chemin passe dans du JSON (non converti), il doit être natif.
command -v cygpath >/dev/null && TMP=$(cygpath -m "$TMP")
trap 'rm -rf "$TMP"' EXIT
fail=0
if command -v py >/dev/null 2>&1; then PY=(py -3); else PY=(python3); fi

# t <attendu: block|pass> <libellé> <stop_hook_active: true|false> <étapes...>
# Étapes : prompt | edit:<chemin> | bash
t() {
  expected=$1 label=$2 active=$3; shift 3
  f="$TMP/t.jsonl"
  "${PY[@]}" - "$f" "$@" <<'PY'
import json, sys
out = []
for step in sys.argv[2:]:
    if step == "prompt":
        out.append({"type": "user", "message": {"content": "do it"}})
    elif step == "bash":
        out.append({"type": "assistant", "message": {"content": [{"type": "tool_use", "name": "Bash", "input": {"command": "npm test"}}]}})
        out.append({"type": "user", "message": {"content": [{"type": "tool_result", "content": "ok"}]}})
    else:
        out.append({"type": "assistant", "message": {"content": [{"type": "tool_use", "name": "Edit", "input": {"file_path": step[5:]}}]}})
        out.append({"type": "user", "message": {"content": [{"type": "tool_result", "content": "ok"}]}})
with open(sys.argv[1], "w", encoding="utf-8") as fh:
    fh.write("\n".join(json.dumps(e) for e in out) + "\n")
PY
  out=$(printf '{"transcript_path":"%s","stop_hook_active":%s}' "$f" "$active" | "$H")
  got=pass; grep -q '"decision": "block"' <<<"$out" && got=block
  mark=ok; [ "$got" = "$expected" ] || { mark=FAIL; fail=1; }
  printf '  %-4s %-5s %s\n' "$mark" "$got" "$label"
}
t block "edit code, no check"            false prompt edit:src/app.ts
t pass  "edit code then bash"            false prompt edit:src/app.ts bash
t block "bash then edit code"            false prompt bash edit:src/app.ts
t pass  "edit doc only"                  false prompt edit:README.md
t pass  "edit in previous turn"          false prompt edit:src/app.ts prompt
t pass  "second stop (hook active)"      true  prompt edit:src/app.ts
t pass  "no edit"                        false prompt bash
out=$(printf '{"transcript_path":"%s/missing.jsonl"}' "$TMP" | "$H"; echo "exit=$?")
[ "$out" = "exit=0" ] && echo "  ok   pass  missing transcript" || { echo "  FAIL missing transcript: $out"; fail=1; }
exit "$fail"
