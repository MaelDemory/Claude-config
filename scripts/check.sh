#!/bin/bash
# Valide la config du repo avant commit / en CI.
#
# Parameters
#   aucun (lancé depuis n'importe où ; travaille sur le repo contenant le script).
# What it does
#   Vérifie : frontmatter des agents (name, description, model, tools) et des
#   skills (name, description) ; name = nom de fichier/dossier ; chaque entrée
#   de external-skills.txt pointe vers un SKILL.md dont le name correspond ;
#   chaque skill/agent cité dans le harnais, les agents et les skills existe ;
#   absence de chemins /Users/<user> ou C:\Users\<user> en dur ; JSON valide de
#   settings.template.json ; syntaxe bash des scripts ; cas du hook
#   guard-secrets et verify-before-stop ; install.sh passe deux
#   fois de suite dans un CLAUDE_CONFIG_DIR temporaire, la 2e sans rien ajouter.
# Output
#   Journal sur stdout ; code retour 1 si au moins une vérification échoue.

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR" || exit 1
FAIL=0
fail() { echo "  ÉCHEC: $*"; FAIL=1; }

# Windows : `python3`/`python` peuvent être le stub du Microsoft Store (présent
# dans le PATH mais en échec) ; on valide par un vrai run, puis `py -3`.
export PYTHONIOENCODING=utf-8
PY=()
for cand in python3 python "py -3"; do
  # shellcheck disable=SC2086  # "py -3" doit être découpé
  if $cand -c pass >/dev/null 2>&1; then read -ra PY <<<"$cand"; break; fi
done
[ ${#PY[@]} -gt 0 ] || { echo "python3 requis"; exit 1; }

echo "== Frontmatter agents/skills"
"${PY[@]}" - <<'EOF' || FAIL=1
import pathlib, sys
rules = {".claude/agents": {"name", "description", "model", "tools", "skills"},
         ".claude/skills": {"name", "description", "when_to_use"},
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

echo "== Références skills/agents"
# Un nom en `kebab-case` cité dans le harnais, un agent ou une skill (ou listé
# dans le `skills:` d'un agent) doit exister : agent, skill maison, externe ou
# optionnelle. Évite les renvois morts après une suppression ou un renommage.
"${PY[@]}" - <<'EOF' || FAIL=1
import pathlib, re, sys
known = {p.stem for p in pathlib.Path(".claude/agents").glob("*.md")}
for d in (".claude/skills", "optional/skills"):
    known |= {p.name for p in pathlib.Path(d).iterdir() if p.is_dir()}
known |= {l.split()[0] for l in open("external-skills.txt", encoding="utf-8") if l.strip() and not l.startswith("#")}
known |= {"prefers-reduced-motion"}  # propriété CSS, pas une skill
files = [pathlib.Path("dev-harness.md"), *pathlib.Path(".claude/agents").glob("*.md"), *pathlib.Path(".claude/skills").glob("*/SKILL.md")]
bad = 0
for f in files:
    text = f.read_text(encoding="utf-8")
    refs = set(re.findall(r"`([a-z0-9]+(?:-[a-z0-9]+)+)`", text))
    if text.startswith("---"):
        refs |= set(re.findall(r"^\s+-\s+([\w-]+)\s*$", text.split("---")[1], re.M))
    for ref in sorted(refs - known):
        print(f"  ÉCHEC: {f.as_posix()} cite `{ref}`, introuvable"); bad = 1
if not bad:
    print("  ok")
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
"${PY[@]}" -c 'import json,sys; json.load(open(sys.argv[1]))' settings.template.json && echo "  ok" || fail "settings.template.json invalide"

echo "== Syntaxe bash"
for f in install.sh scripts/*.sh .claude/hooks/*.sh; do
  bash -n "$f" || fail "$f"
done
command -v shellcheck >/dev/null && { shellcheck -S warning install.sh scripts/*.sh .claude/hooks/*.sh || fail "shellcheck"; }
echo "  ok"

echo "== Hook guard-secrets"
if out=$(bash scripts/test-guard-secrets.sh); then
  echo "  ok"
else
  printf '%s\n' "$out" | grep FAIL
  fail "guard-secrets.sh ne bloque/autorise pas les cas attendus"
fi

echo "== Hook verify-before-stop"
if out=$(bash scripts/test-verify-before-stop.sh); then
  echo "  ok"
else
  printf '%s\n' "$out" | grep FAIL
  fail "verify-before-stop.sh ne bloque/autorise pas les cas attendus"
fi

echo "== install.sh x2 (idempotence)"
TMP=$(mktemp -d)
if CLAUDE_CONFIG_DIR="$TMP" ./install.sh >/dev/null && second=$(CLAUDE_CONFIG_DIR="$TMP" ./install.sh); then
  if grep -q "settings.json : 0 règle(s) de permission et 0 hook(s) ajoutés, 0 réglage(s) posé(s)" <<<"$second"; then
    echo "  ok"
  else
    fail "la 2e installation a encore modifié settings.json"
  fi
  "${PY[@]}" -c 'import json,sys; json.load(open(sys.argv[1]))' "$TMP/settings.json" || fail "settings.json installé invalide"
  # Une copie posée par une installation précédente puis retirée du repo doit disparaître.
  mkdir -p "$TMP/skills/zz-orphan" "$TMP/skills/zz-user-skill" && echo "skills/zz-orphan" >> "$TMP/.claude-starter-manifest"
  CLAUDE_CONFIG_DIR="$TMP" ./install.sh >/dev/null || fail "install.sh a échoué (3e passe)"
  [ ! -e "$TMP/skills/zz-orphan" ] || fail "copie orpheline non retirée"
  [ -d "$TMP/skills/zz-user-skill" ] || fail "skill hors manifeste supprimée à tort"
else
  fail "install.sh a échoué"
fi
rm -rf "$TMP"

[ "$FAIL" = 0 ] && echo && echo "Toutes les vérifications passent." || { echo; echo "Des vérifications ont échoué."; }
exit "$FAIL"
