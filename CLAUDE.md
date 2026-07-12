# CLAUDE.md — repo starter config Claude Code

Ce repo est une config starter Claude Code installable via `./install.sh` (voir `README.md`).

- La source de vérité de la config est `.claude/` (agents, skills, hooks) et `dev-harness.md` ; `settings.template.json` sert de base au settings global.
- `~/.claude` reçoit des **symlinks** vers ce repo : toute modification ici est immédiatement globale. Modifie avec la même prudence qu'une config de prod.
- `.opencode/` et `.openclaw/` sont les configs d'origine, en lecture seule pour référence — ne pas les modifier ni les « nettoyer ».
- Quand un agent ou une skill est modifié, garder la parité : frontmatter valide (name + description), chemins portables (`~/…`, jamais de `/Users/<user>` en dur), templates de sortie inchangés sauf demande explicite.
- Tester `install.sh` après modification : `CLAUDE_CONFIG_DIR=$(mktemp -d) ./install.sh` doit passer sans erreur, deux fois de suite (idempotence).
