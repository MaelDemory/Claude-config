#!/bin/bash
# Installe la config starter Claude Code dans ~/.claude (ou $CLAUDE_CONFIG_DIR).
#
# Parameters
#   $1  mode optionnel : "link" (défaut, symlinks — `git pull` met à jour partout)
#       ou "copy" (copies indépendantes du repo).
# What it does
#   Symlinke/copie les agents, skills, hooks et le harnais dev-harness.md dans
#   la config globale Claude Code, ajoute l'import @dev-harness.md au CLAUDE.md
#   global, et installe/fusionne settings.json (permissions ; hooks uniquement
#   à la création, et hooks de notification macOS exclus hors Darwin). Les
#   skills optionnelles (optional/skills/) ne sont PAS installées. Requiert
#   python3 (ou python) pour créer/fusionner settings.json hors macOS. Les
#   fichiers existants non-symlinks sont sauvegardés dans ~/.claude/backups/.
#   Initialise aussi les submodules (skills externes) si .gitmodules existe.
#   Idempotent : relançable sans effet de bord.
# Output
#   Journal des actions sur stdout ; code retour non nul en cas d'échec.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
MODE="${1:-link}"
BACKUP_DIR="$DEST/backups/claude-starter-$(date +%Y%m%d-%H%M%S)"

if [ "$MODE" != "link" ] && [ "$MODE" != "copy" ]; then
  echo "Usage: $0 [link|copy]" >&2
  exit 1
fi

mkdir -p "$DEST/agents" "$DEST/skills" "$DEST/hooks"

# Certaines skills sont livrées en submodule (ex. apple-design) : après un clone
# sans --recurse-submodules leur dossier est vide, ce qui produirait une skill
# cassée. On les initialise ici pour que l'install marche quel que soit le clone.
if [ -f "$REPO_DIR/.gitmodules" ] && command -v git >/dev/null 2>&1; then
  echo "== Submodules"
  git -C "$REPO_DIR" submodule update --init --recursive || \
    echo "  ATTENTION: init des submodules échouée (réseau ?) — skills concernées ignorées."
fi

place() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/"
    echo "  sauvegarde: $dst -> $BACKUP_DIR/"
  fi
  if [ "$MODE" = "copy" ]; then
    rm -rf "$dst"
    cp -R "$src" "$dst"
  else
    ln -sfn "$src" "$dst"
  fi
}

echo "== Agents -> $DEST/agents/"
for f in "$REPO_DIR/.claude/agents/"*.md; do
  place "$f" "$DEST/agents/$(basename "$f")"
done

echo "== Skills -> $DEST/skills/"
for d in "$REPO_DIR/.claude/skills/"*/; do
  if [ ! -f "${d}SKILL.md" ]; then
    echo "  ignoré: $(basename "$d") (pas de SKILL.md — submodule non initialisé ?)"
    continue
  fi
  place "${d%/}" "$DEST/skills/$(basename "$d")"
done

echo "== Hooks -> $DEST/hooks/"
place "$REPO_DIR/.claude/hooks/rtk-rewrite.sh" "$DEST/hooks/rtk-rewrite.sh"
chmod +x "$DEST/hooks/rtk-rewrite.sh" 2>/dev/null || true

echo "== Harnais -> $DEST/dev-harness.md"
place "$REPO_DIR/dev-harness.md" "$DEST/dev-harness.md"

echo "== Import dans $DEST/CLAUDE.md"
if [ ! -f "$DEST/CLAUDE.md" ]; then
  printf '# CLAUDE.md\n\n## Dev Harness\n\n@dev-harness.md\n' > "$DEST/CLAUDE.md"
  echo "  CLAUDE.md créé avec l'import @dev-harness.md"
elif ! grep -q '@dev-harness.md' "$DEST/CLAUDE.md"; then
  printf '\n## Dev Harness\n\n@dev-harness.md\n' >> "$DEST/CLAUDE.md"
  echo "  import @dev-harness.md ajouté"
else
  echo "  import déjà présent"
fi

echo "== Settings"
# Détection robuste : le stub Microsoft Store de `python` sous Windows existe
# dans le PATH mais échoue à l'exécution — on valide donc par un run réel.
PYBIN=""
for cand in python3 python; do
  if command -v "$cand" >/dev/null 2>&1 && "$cand" -c 'pass' >/dev/null 2>&1; then
    PYBIN="$cand"
    break
  fi
done
if [ ! -f "$DEST/settings.json" ]; then
  if [ "$(uname)" = "Darwin" ]; then
    cp "$REPO_DIR/settings.template.json" "$DEST/settings.json"
    echo "  settings.json créé depuis settings.template.json (permissions + hooks)"
  elif [ -n "$PYBIN" ]; then
    # Hors macOS : les hooks Notification/Stop (osascript/afplay) sont exclus ;
    # le hook PreToolUse rtk (bash + jq) est conservé.
    "$PYBIN" - "$REPO_DIR/settings.template.json" "$DEST/settings.json" <<'EOF'
import json, sys
tmpl = json.load(open(sys.argv[1]))
hooks = tmpl.get("hooks", {})
hooks.pop("Notification", None)
hooks.pop("Stop", None)
if not hooks:
    tmpl.pop("hooks", None)
json.dump(tmpl, open(sys.argv[2], "w"), indent=2, ensure_ascii=False)
print("  settings.json créé (hooks de notification macOS exclus sur cet OS)")
EOF
  else
    cp "$REPO_DIR/settings.template.json" "$DEST/settings.json"
    echo "  ATTENTION: python3 absent — settings.json copié tel quel ; supprime"
    echo "  manuellement les hooks Notification/Stop (osascript/afplay, macOS uniquement)."
  fi
else
  if [ -n "$PYBIN" ]; then
    "$PYBIN" - "$DEST/settings.json" "$REPO_DIR/settings.template.json" <<'EOF'
import json, sys
dest_path, tmpl_path = sys.argv[1], sys.argv[2]
dest = json.load(open(dest_path))
tmpl = json.load(open(tmpl_path))
allow = dest.setdefault("permissions", {}).setdefault("allow", [])
added = [r for r in tmpl["permissions"]["allow"] if r not in allow]
allow.extend(added)
json.dump(dest, open(dest_path, "w"), indent=2, ensure_ascii=False)
print(f"  permissions fusionnées ({len(added)} règle(s) ajoutée(s))")
print("  hooks NON modifiés (settings.json existant) — voir settings.template.json")
EOF
  else
    echo "  ATTENTION: python3 absent — fusion des permissions ignorée ;"
    echo "  ajoute manuellement les règles de settings.template.json à $DEST/settings.json."
  fi
fi

echo
echo "Installation terminée ($MODE). Redémarre les sessions Claude Code pour appliquer."
