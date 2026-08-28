# CLAUDE.md — repo starter config Claude Code

Ce repo est une config starter Claude Code installable via `./install.sh` (voir `README.md`).

- La source de vérité de la config est `.claude/` (agents, skills, hooks) et `dev-harness.md` ; `settings.template.json` sert de base au settings global.
- `~/.claude` reçoit des **symlinks** vers ce repo : toute modification ici est immédiatement globale. Modifie avec la même prudence qu'une config de prod.
- `.opencode/` et `.openclaw/` sont les configs d'origine, en lecture seule pour référence — ne pas les modifier ni les « nettoyer ».
- Quand un agent ou une skill est modifié, garder la parité : frontmatter valide (agents : uniquement `name`, `description`, `model`, `tools` ; skills : `name` + `description`), chemins portables (`~/…`, jamais de `/Users/<user>` en dur), templates de sortie inchangés sauf demande explicite.
- Chemins vault : jamais en dur dans les skills/agents — utiliser `<vault-root>` / `<legacy-vault-root>`, définis une seule fois dans `## Vault configuration` de `dev-harness.md`.
- `optional/skills/` contient les skills personnelles (investissement, contenu) non installées par défaut ; ne pas les redéplacer dans `.claude/skills/`.
- Tester `install.sh` après modification : `CLAUDE_CONFIG_DIR=$(mktemp -d) ./install.sh` doit passer sans erreur, deux fois de suite (idempotence).
- `install.ps1` est l'équivalent Windows d'`install.sh` (copie par défaut, pas de hooks) : toute évolution de l'un doit être répercutée sur l'autre. Non testable sur macOS — le signaler dans le commit si modifié sans test.
