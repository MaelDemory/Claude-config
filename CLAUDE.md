# CLAUDE.md — repo starter config Claude Code

Ce repo est une config Claude Code installable via `./install.sh` (voir `README.md`). Il ne contient que de la config Claude Code.

- La source de vérité est `.claude/` (agents, skills, hooks) et `dev-harness.md` ; `settings.template.json` sert de base au settings global.
- `~/.claude` reçoit des **symlinks** vers ce repo : toute modification ici est immédiatement globale. Modifie avec la même prudence qu'une config de prod.
- Parité agents/skills : frontmatter valide (agents : uniquement `name`, `description`, `model`, `tools` ; skills : `name` + `description`), descriptions au format « <ce que ça fait>. Use when… » (agents délégables : « Use proactively when… »), chemins portables (`~/…`, jamais de `/Users/<user>` en dur), templates de sortie inchangés sauf demande explicite.
- Esprit du harnais (`dev-harness.md`) : guidelines Karpathy (réfléchir avant, simplicité, changements chirurgicaux, critères vérifiables) + `lessons.md` par projet. Pas de vault, pas de fichiers d'état supplémentaires : garder la config petite.
- `optional/skills/` contient les skills personnelles (investissement, contenu) non installées par défaut ; ne pas les redéplacer dans `.claude/skills/`.
- Skills tierces : submodules dans `vendor/` + une ligne dans `external-skills.txt` (`<nom> <dossier du SKILL.md>`). Ne jamais éditer `vendor/` ; une skill maison ne doit pas porter le nom d'une skill externe.
- Après toute modification : `./scripts/check.sh` doit passer (frontmatter, chemins en dur, JSON, syntaxe bash, `install.sh` deux fois de suite). La CI (`.github/workflows/check.yml`) le rejoue sur Linux/macOS et teste `install.ps1` sur Windows.
- `install.ps1` est l'équivalent Windows d'`install.sh` (copie par défaut, pas de hooks) : toute évolution de l'un doit être répercutée sur l'autre.
- Nouveau hook : script dans `.claude/hooks/*.sh` (installé automatiquement) + entrée dans `settings.template.json` (fusionnée par `install.sh` si absente).
