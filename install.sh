#!/bin/bash
# Installe la config starter Claude Code dans ~/.claude (ou $CLAUDE_CONFIG_DIR).
#
# Parameters
#   $1  mode optionnel : "link" (défaut, symlinks — `git pull` met à jour partout)
#       ou "copy" (copies indépendantes du repo).
# What it does
#   Symlinke/copie les agents, skills, hooks et le harnais dev-harness.md dans
#   la config globale Claude Code, ajoute l'import @dev-harness.md au CLAUDE.md
#   global, et crée/fusionne settings.json : règles allow/ask/deny unies,
#   defaultMode posé s'il est absent, hooks du template ajoutés s'ils manquent
#   (jamais supprimés ; hooks osascript/afplay exclus hors macOS). Les
#   skills optionnelles (optional/skills/) ne sont PAS installées. Requiert
#   python3 (ou python) pour créer/fusionner settings.json. Les
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
  place "${d%/}" "$DEST/skills/$(basename "$d")"
done

echo "== Skills externes (external-skills.txt) -> $DEST/skills/"
while read -r name path; do
  case "$name" in ''|'#'*) continue ;; esac
  if [ ! -f "$REPO_DIR/$path/SKILL.md" ]; then
    echo "  ignoré: $name (pas de $path/SKILL.md — submodule non initialisé ?)"
    continue
  fi
  place "$REPO_DIR/$path" "$DEST/skills/$name"
done < "$REPO_DIR/external-skills.txt"

echo "== Hooks -> $DEST/hooks/"
for f in "$REPO_DIR/.claude/hooks/"*.sh; do
  place "$f" "$DEST/hooks/$(basename "$f")"
  chmod +x "$DEST/hooks/$(basename "$f")" 2>/dev/null || true
done

echo "== Nettoyage des liens orphelins"
# Un agent/skill/hook supprimé du repo laisse un symlink cassé dans $DEST :
# on ne retire que les liens qui pointent dans ce repo vers une cible absente.
for link in "$DEST/agents/"* "$DEST/skills/"* "$DEST/hooks/"*; do
  [ -L "$link" ] || continue
  target=$(readlink "$link")
  case "$target" in
    "$REPO_DIR"/*) [ -e "$target" ] || { rm "$link"; echo "  retiré: $link"; } ;;
  esac
done

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
if [ -z "$PYBIN" ]; then
  if [ ! -f "$DEST/settings.json" ] && [ "$(uname)" = "Darwin" ]; then
    cp "$REPO_DIR/settings.template.json" "$DEST/settings.json"
    echo "  settings.json créé depuis settings.template.json"
  else
    echo "  ATTENTION: python3 absent — settings.json non créé/fusionné ;"
    echo "  reporte manuellement settings.template.json dans $DEST/settings.json."
  fi
else
  # Fusion additive et idempotente : rien n'est jamais retiré des settings
  # existants. Hors macOS, les hooks osascript/afplay sont ignorés.
  "$PYBIN" - "$DEST/settings.json" "$REPO_DIR/settings.template.json" "$(uname)" <<'EOF'
import json, os, sys
dest_path, tmpl_path, system = sys.argv[1:4]
dest = json.load(open(dest_path)) if os.path.exists(dest_path) else {}
tmpl = json.load(open(tmpl_path))

perms = dest.setdefault("permissions", {})
added = 0
for key in ("allow", "ask", "deny"):
    rules = perms.setdefault(key, [])
    for rule in tmpl["permissions"].get(key, []):
        if rule not in rules:
            rules.append(rule)
            added += 1
if "defaultMode" in tmpl["permissions"]:
    perms.setdefault("defaultMode", tmpl["permissions"]["defaultMode"])

def commands(groups):
    return {h.get("command") for g in groups for h in g.get("hooks", [])}

hooks_added = 0
for event, groups in tmpl.get("hooks", {}).items():
    current = dest.setdefault("hooks", {}).setdefault(event, [])
    for group in groups:
        cmds = [h.get("command", "") for h in group.get("hooks", [])]
        if system != "Darwin" and any("osascript" in c or "afplay" in c for c in cmds):
            continue
        if not set(cmds) & commands(current):
            current.append(group)
            hooks_added += 1
    if not current:
        dest["hooks"].pop(event)

json.dump(dest, open(dest_path, "w"), indent=2, ensure_ascii=False)
print(f"  settings.json : {added} règle(s) de permission et {hooks_added} hook(s) ajoutés")
EOF
fi

echo
echo "Installation terminée ($MODE). Redémarre les sessions Claude Code pour appliquer."
