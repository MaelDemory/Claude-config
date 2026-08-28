# Claude Code Starter Config

Config starter pour [Claude Code](https://code.claude.com) : 13 subagents spécialisés, 25 skills avec templates (+ 5 optionnelles), hooks et harnais de workflow (plan → build → review → simplify → test → wrap-up). Adaptée d'un harnais OpenCode (conservé dans `.opencode/` pour référence).

## Installation sur un nouveau poste

### macOS / Linux

```bash
git clone <url-du-repo> workflow-ia
cd workflow-ia
./install.sh
```

C'est tout. Redémarre tes sessions Claude Code pour appliquer.

Par défaut l'installation **symlinke** vers le clone : un `git pull` dans le repo met à jour la config de tout le poste. Pour des copies indépendantes :

```bash
./install.sh copy
```

L'installeur est idempotent (relançable sans risque) et sauvegarde tout fichier existant qu'il remplace dans `~/.claude/backups/`.

### Windows

```powershell
git clone <url-du-repo> workflow-ia
cd workflow-ia
powershell -ExecutionPolicy Bypass -File install.ps1
```

Différences avec macOS/Linux :

- Mode **copie** par défaut (les symlinks Windows exigent le mode développeur ou une console admin) : après un `git pull`, relance `install.ps1` pour propager. Pour des symlinks quand même : `install.ps1 -Mode link`.
- Les **hooks du template ne sont pas installés** (rtk-rewrite est un script bash, les notifications utilisent `osascript`/`afplay` — macOS uniquement). Seules les permissions sont créées/fusionnées dans `settings.json`.
- Sous **Git Bash/WSL**, `./install.sh copy` fonctionne aussi.

## Ce qui est installé

| Source (repo) | Destination | Rôle |
|---|---|---|
| `.claude/agents/*.md` | `~/.claude/agents/` | 13 subagents : planner, plan-contest, architecture, frontend, backend, review, test, cartography, indexer, kanban, vault, file-system, github |
| `.claude/skills/*/` | `~/.claude/skills/` | 25 skills : create-plan, grill-me, wrap-up, frontend-design, commit, vault-search, … (5 skills personnelles supplémentaires dans `optional/skills/`, non installées — voir plus bas) |
| `.claude/hooks/rtk-rewrite.sh` | `~/.claude/hooks/` | Hook PreToolUse : réécrit les commandes Bash via `rtk` (économie de tokens) ; inactif si rtk absent |
| `dev-harness.md` | `~/.claude/dev-harness.md` + import dans `~/.claude/CLAUDE.md` | Harnais : routage des workflows, chaîne de build, discipline de code, règles vault |
| `settings.template.json` | `~/.claude/settings.json` | Permissions (rtk, git en lecture, cmux) + hooks rtk/notifications. **Si un settings.json existe déjà : seules les permissions sont fusionnées, les hooks ne sont jamais touchés** (à reprendre manuellement du template si voulu) |

## Workflow fourni par le harnais

- **Nouveau projet** : `grill-me` → vault `create-project` → Plan Mode / `planner` → `create-plan` + `plan-contest`.
- **Onboarding d'un codebase existant** : `onboard-project` → `cartography` → `indexer` → `memory-write`.
- **Tâche courante** : `start-session` → plan → chaîne de build automatique (frontend/backend → `implementation-review` → `review-code` → `simplify-code` → tests → `wrap-up`).

Détails dans [`dev-harness.md`](dev-harness.md).

## Dépendances par poste (optionnelles)

- `python3` (ou `python`) — requis par `install.sh` pour créer/fusionner `settings.json` (sauf création simple sur macOS). Sans lui, l'installeur avertit et saute cette étape.
- `rtk` + `jq` — réécriture de commandes pour économiser des tokens (le hook a besoin des deux). Sans eux, le hook se désactive tout seul. Si tu utilises déjà `rtk hook claude` dans tes settings, n'ajoute pas le hook du template (doublon).
- `cmux` — vérification visuelle navigateur pour le travail frontend ; les skills dégradent proprement s'il est absent.
- **Vault Obsidian** : les agents `vault`/`kanban` et les skills mémoire attendent un vault dans `~/Documents/ObsidianMemory`. Le chemin est configuré à **un seul endroit** : la section `## Vault configuration` de `dev-harness.md` (les skills référencent `<vault-root>`). Sans vault, les skills répondent « not configured » et continuent.
- Les notifications du template utilisent `osascript`/`afplay` (macOS uniquement) ; `install.sh` les exclut automatiquement sur Linux, `install.ps1` n'installe aucun hook.

## Skills optionnelles (`optional/skills/`)

5 skills personnelles (recherche d'investissement Notion, rédaction LinkedIn/Medium) sont hors de `.claude/` et **ne sont pas installées** : `asset-research-skill`, `sector-research-skill`, `content-post`, `content-article`, `content-weekly`. Elles supposent un MCP Notion configuré et/ou des guides dans le Content Vault. Pour les activer :

```bash
cp -R optional/skills/<nom> .claude/skills/   # puis relance ./install.sh
```

## Ajouter la config à un projet existant

Si tu as installé la config globalement (`./install.sh`), **il n'y a rien à faire** : agents, skills et harnais s'appliquent déjà à tous tes projets.

Embarquer la config *dans* un repo n'est utile que pour la **versionner avec le projet** (la partager avec une équipe, ou figer une variante par projet) :

```bash
cd /chemin/vers/mon-projet

# agents + skills + hooks versionnés dans le projet
mkdir -p .claude
cp -R /chemin/vers/workflow-ia/.claude/agents .claude/agents
cp -R /chemin/vers/workflow-ia/.claude/skills .claude/skills
cp -R /chemin/vers/workflow-ia/.claude/hooks  .claude/hooks

# harnais importé depuis le CLAUDE.md du projet
cp /chemin/vers/workflow-ia/dev-harness.md .
printf '# CLAUDE.md\n\n@dev-harness.md\n' > CLAUDE.md   # ou ajoute juste la ligne @dev-harness.md à ton CLAUDE.md existant

echo '.claude/settings.local.json' >> .gitignore
```

À savoir :

- Si le projet a déjà un `.claude/` ou un `CLAUDE.md`, complète-les au lieu d'écraser (copie les sous-dossiers manquants, ajoute la ligne `@dev-harness.md`).
- En cas de doublon de nom avec la config globale, la version **projet** a priorité — inutile de désinstaller le global.
- Pour des settings partagés au niveau projet, pars de `settings.template.json` vers `.claude/settings.json` en remplaçant `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` par `$CLAUDE_PROJECT_DIR/.claude` dans le chemin du hook.
- Ne copie que ce qui sert au projet : pour un backend seul, par exemple, les skills vault/kanban peuvent être omises. Les skills personnelles (`optional/skills/`) ne se copient que si le projet en a l'usage.

## Personnalisation

- La source de vérité est le repo : édite `.claude/agents/`, `.claude/skills/`, `dev-harness.md`, puis commit. En mode symlink, tous les postes suivent via `git pull`.
- Pour déplacer le vault Obsidian, édite uniquement la section `## Vault configuration` de `dev-harness.md`.
- Deux skills sont renommées pour éviter des collisions : `simplify-code` (skill built-in `simplify` de Claude Code) et `cartography-map` (l'agent `cartography` garde ce nom).
- `.opencode/` et `.openclaw/` sont les configs d'origine (OpenCode / OpenClaw), conservées pour référence — rien n'y est installé.

## Désinstallation

Supprime les symlinks/copies dans `~/.claude/agents`, `~/.claude/skills`, `~/.claude/hooks/rtk-rewrite.sh`, `~/.claude/dev-harness.md`, et retire la section `## Dev Harness` de `~/.claude/CLAUDE.md`.
