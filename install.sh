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
#   à la création). Les fichiers existants non-symlinks sont sauvegardés dans
#   ~/.claude/backups/. Idempotent : relançable sans effet de bord.
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
if [ ! -f "$DEST/settings.json" ]; then
  cp "$REPO_DIR/settings.template.json" "$DEST/settings.json"
  echo "  settings.json créé depuis settings.template.json (permissions + hooks)"
else
  python3 - "$DEST/settings.json" "$REPO_DIR/settings.template.json" <<'EOF'
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
fi

echo
echo "Installation terminée ($MODE). Redémarre les sessions Claude Code pour appliquer."
