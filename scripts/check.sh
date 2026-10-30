#!/bin/bash
# Valide la config du repo avant commit / en CI.
#
# Parameters
#   aucun (lancé depuis n'importe où ; travaille sur le repo contenant le script).
# What it does
#   Vérifie : frontmatter des agents (name, description, model, tools) et des
#   skills (name, description) ; name = nom de fichier/dossier ; chaque entrée
#   de external-skills.txt pointe vers un SKILL.md dont le name correspond ;
#   absence de chemins /Users/<user> ou C:\Users\<user> en dur ; JSON valide de
#   settings.template.json ; syntaxe bash des scripts ; install.sh passe deux
#   fois de suite dans un CLAUDE_CONFIG_DIR temporaire, la 2e sans rien ajouter.
# Output
#   Journal sur stdout ; code retour 1 si au moins une vérification échoue.

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR" || exit 1
FAIL=0
fail() { echo "  ÉCHEC: $*"; FAIL=1; }

PYBIN=$(command -v python3 || command -v python) || { echo "python3 requis"; exit 1; }

echo "== Frontmatter agents/skills"
"$PYBIN" - <<'EOF' || FAIL=1
import pathlib, sys
rules = {".claude/agents": {"name", "description", "model", "tools"},
         ".claude/skills": {"name", "description"},
         "optional/skills": {"name", "description"}}
bad = 0
def frontmatter(path):
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "---":
        return None
    keys, current = {}, None
    for line in lines[1:]:
        if line == "---":
            return keys
        if line[:1] not in (" ", "\t", "") and ":" in line:
            current, value = line.split(":", 1)
            keys[current.strip()] = value.strip()
    return None
for root, allowed in rules.items():
    files = (pathlib.Path(root).glob("*.md") if root.endswith("agents")
             else pathlib.Path(root).glob("*/SKILL.md"))
    for f in sorted(files):
        expected = f.stem if root.endswith("agents") else f.parent.name
        fm = frontmatter(f)
        if fm is None:
            print(f"  ÉCHEC: {f} — frontmatter absent ou non fermé"); bad = 1; continue
        if set(fm) - allowed:
            print(f"  ÉCHEC: {f} — clés non autorisées {sorted(set(fm) - allowed)}"); bad = 1
        if fm.get("name") != expected:
            print(f"  ÉCHEC: {f} — name '{fm.get('name')}' != '{expected}'"); bad = 1
        if not fm.get("description"):
            print(f"  ÉCHEC: {f} — description vide"); bad = 1
for line in pathlib.Path("external-skills.txt").read_text(encoding="utf-8").splitlines():
    if not line.strip() or line.startswith("#"):
        continue
    name, path = line.split(None, 1)
    f = pathlib.Path(path.strip()) / "SKILL.md"
    if not f.is_file():
        print(f"  ÉCHEC: external-skills.txt — {f} introuvable (submodule non initialisé ?)"); bad = 1; continue
    fm = frontmatter(f) or {}
    if fm.get("name", "").strip('"') != name:
        print(f"  ÉCHEC: external-skills.txt — {name} != name '{fm.get('name')}' dans {f}"); bad = 1
    if pathlib.Path(".claude/skills", name).exists():
        print(f"  ÉCHEC: external-skills.txt — {name} existe aussi dans .claude/skills"); bad = 1
print("  ok" if not bad else "  frontmatter invalide")
sys.exit(bad)
EOF

echo "== Chemins utilisateur en dur"
EXCLUDES=(--exclude-dir=.git --exclude-dir=vendor --exclude=check.sh)
if grep -rnE '/Users/[A-Za-z0-9._-]+/|C:\\Users\\[A-Za-z]' "${EXCLUDES[@]}" . | grep -v '<user>'; then
  fail "chemins en dur ci-dessus (utilise ~)"
else
  echo "  ok"
fi

echo "== JSON"
"$PYBIN" -c 'import json,sys; json.load(open(sys.argv[1]))' settings.template.json && echo "  ok" || fail "settings.template.json invalide"

echo "== Syntaxe bash"
for f in install.sh scripts/*.sh .claude/hooks/*.sh; do
  bash -n "$f" || fail "$f"
done
command -v shellcheck >/dev/null && { shellcheck -S warning install.sh scripts/*.sh .claude/hooks/*.sh || fail "shellcheck"; }
echo "  ok"

echo "== install.sh x2 (idempotence)"
TMP=$(mktemp -d)
if CLAUDE_CONFIG_DIR="$TMP" ./install.sh >/dev/null && second=$(CLAUDE_CONFIG_DIR="$TMP" ./install.sh); then
  if grep -q "settings.json : 0 règle(s) de permission et 0 hook(s) ajoutés" <<<"$second"; then
    echo "  ok"
  else
    fail "la 2e installation a encore modifié settings.json"
  fi
  "$PYBIN" -c 'import json,sys; json.load(open(sys.argv[1]))' "$TMP/settings.json" || fail "settings.json installé invalide"
else
  fail "install.sh a échoué"
fi
rm -rf "$TMP"

[ "$FAIL" = 0 ] && echo && echo "Toutes les vérifications passent." || { echo; echo "Des vérifications ont échoué."; }
exit "$FAIL"
