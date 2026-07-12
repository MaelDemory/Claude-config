# Claude Code Starter Config

Config starter pour [Claude Code](https://code.claude.com) : 13 subagents spécialisés, 30 skills avec templates, hooks et harnais de workflow (plan → build → review → simplify → test → wrap-up). Adaptée d'un harnais OpenCode (conservé dans `.opencode/` pour référence).

## Installation sur un nouveau poste

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

## Ce qui est installé

| Source (repo) | Destination | Rôle |
|---|---|---|
| `.claude/agents/*.md` | `~/.claude/agents/` | 13 subagents : planner, plan-contest, architecture, frontend, backend, review, test, cartography, indexor, kanban, vault, file-system, github |
| `.claude/skills/*/` | `~/.claude/skills/` | 30 skills : create-plan, grill-me, wrap-up, frontend-design, commit, vault-search, … |
| `.claude/hooks/rtk-rewrite.sh` | `~/.claude/hooks/` | Hook PreToolUse : réécrit les commandes Bash via `rtk` (économie de tokens) ; inactif si rtk absent |
| `dev-harness.md` | `~/.claude/dev-harness.md` + import dans `~/.claude/CLAUDE.md` | Harnais : routage des workflows, chaîne de build, discipline de code, règles vault |
| `settings.template.json` | `~/.claude/settings.json` | Permissions (rtk, git en lecture, cmux) + hooks rtk/notifications. **Si un settings.json existe déjà : seules les permissions sont fusionnées, les hooks ne sont jamais touchés** (à reprendre manuellement du template si voulu) |

## Workflow fourni par le harnais

- **Nouveau projet** : `grill-me` → vault `create-project` → Plan Mode / `planner` → `create-plan` + `plan-contest`.
- **Onboarding d'un codebase existant** : `onboard-project` → `cartography` → `indexor` → `memory-write`.
- **Tâche courante** : `start-session` → plan → chaîne de build automatique (frontend/backend → `implementation-review` → `review-code` → `simplify` → tests → `wrap-up`).

Détails dans [`dev-harness.md`](dev-harness.md).

## Dépendances par poste (optionnelles)

- `rtk` — réécriture de commandes pour économiser des tokens. Sans lui, le hook se désactive tout seul. Si tu utilises déjà `rtk hook claude` dans tes settings, n'ajoute pas le hook du template (doublon).
- `cmux` — vérification visuelle navigateur pour le travail frontend ; les skills dégradent proprement s'il est absent.
- **Vault Obsidian** : les agents `vault`/`kanban` et les skills mémoire attendent un vault dans `~/Documents/ObsidianMemory` (structure : `Dev Vault/`, `PM/Projects/`, `PM/Tasks/`, …). Crée-le ou adapte les chemins dans les skills concernées.
- Les notifications du template utilisent `osascript`/`afplay` (macOS uniquement).

## Personnalisation

- La source de vérité est le repo : édite `.claude/agents/`, `.claude/skills/`, `dev-harness.md`, puis commit. En mode symlink, tous les postes suivent via `git pull`.
- La skill `simplify` porte le même nom qu'une skill built-in de Claude Code ; renomme le dossier si cela crée un conflit chez toi.
- `.opencode/` et `.openclaw/` sont les configs d'origine (OpenCode / OpenClaw), conservées pour référence — rien n'y est installé.

## Désinstallation

Supprime les symlinks/copies dans `~/.claude/agents`, `~/.claude/skills`, `~/.claude/hooks/rtk-rewrite.sh`, `~/.claude/dev-harness.md`, et retire la section `## Dev Harness` de `~/.claude/CLAUDE.md`.
