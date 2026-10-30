# Claude Code Config

Config [Claude Code](https://code.claude.com) dans l'esprit des guidelines d'Andrej Karpathy : **réfléchir avant de coder, simplicité, changements chirurgicaux, exécution pilotée par des critères vérifiables**. Une fois le but clair, Claude choisit son workflow et boucle seul jusqu'à la vérification. La mémoire de chaque projet tient dans un seul fichier : `lessons.md`.

## Installation

### macOS / Linux

```bash
git clone --recurse-submodules <url-du-repo> claude-config
cd claude-config
./install.sh          # symlinks (défaut) : un `git pull` met à jour tout le poste
./install.sh copy     # ou copies indépendantes
```

Redémarre tes sessions Claude Code pour appliquer. L'installeur est idempotent : relance-le après chaque `git pull` qui ajoute ou supprime des fichiers. Il sauvegarde ce qu'il remplace dans `~/.claude/backups/`, initialise les submodules si besoin et retire les symlinks devenus orphelins (agents/skills supprimés du repo).

### Windows

```powershell
git clone --recurse-submodules <url-du-repo> claude-config
cd claude-config
powershell -ExecutionPolicy Bypass -File install.ps1          # copie (défaut)
powershell -ExecutionPolicy Bypass -File install.ps1 -Mode link   # symlinks (mode développeur ou admin)
```

Les hooks (scripts bash, notifications macOS) ne sont pas installés sous Windows : seules les permissions sont fusionnées dans `settings.json`. Sous Git Bash/WSL, `./install.sh copy` fonctionne aussi.

## Ce qui est installé

| Source (repo) | Destination | Rôle |
|---|---|---|
| `dev-harness.md` | `~/.claude/dev-harness.md` + import dans `~/.claude/CLAUDE.md` | Le harnais : les 4 principes, `lessons.md`, autonomie et garde-fous, workflow proportionné |
| `.claude/agents/*.md` | `~/.claude/agents/` | 8 subagents : `planner`, `plan-contest`, `architecture`, `frontend`, `backend`, `review`, `test`, `github` |
| `.claude/skills/*/` | `~/.claude/skills/` | 13 skills maison : `ship` (livraison de bout en bout), `add-skill` (ajouter une skill au repo), `create-plan`, `grill-me`, `implementation-review`, `review-code`, `simplify-code`, `test-code`, `wrap-up`, `commit`, `create-pr`, `comment`, `create-architecture` |
| `external-skills.txt` → `vendor/` | `~/.claude/skills/` | 10 skills externes (submodules), voir plus bas |
| `.claude/hooks/*.sh` | `~/.claude/hooks/` | `session-context.sh` (SessionStart : état git, plans ouverts et `lessons.md` injectés à chaque session) ; `guard-secrets.sh` (bloque la lecture de secrets en Bash) ; `rtk-rewrite.sh` (réécrit les commandes via `rtk` pour économiser des tokens, inactif si rtk absent) |
| `settings.template.json` | `~/.claude/settings.json` | **allow** large (lecture, git local, tests/builds courants, gh en lecture), **ask** pour l'irréversible (push, `reset --hard`, `rm -rf`, PR, publish), **deny** pour les secrets et le force-push, hooks. Réglages de découverte des skills : budget de la liste porté à 2 % du contexte (`skillListingBudgetFraction`), descriptions plafonnées à 500 caractères (`skillListingMaxDescChars`), `commit`/`create-pr` listés par leur seul nom (`skillOverrides`). Fusion additive : rien n'est jamais retiré ni écrasé dans un settings.json existant |

## Comment ça marche

- **Avant de coder** : Claude énonce ses hypothèses, présente les interprétations concurrentes et pose ses questions *avant* d'écrire du code, pas après une erreur.
- **Pendant** : code minimal, aucun changement hors demande ; chaque ligne modifiée se rattache à la requête.
- **Boucle autonome** : la tâche devient un critère vérifiable (un test, une commande) ; Claude implémente, vérifie, corrige, et s'arrête après deux échecs avec les preuves.
- **Workflow proportionné** : petit changement = vérification seule ; moyen = review + tests ; gros = plan + `plan-contest` + review + simplify + tests. `ship` déroule tout.
- **`lessons.md`** : à la racine de chaque projet, les règles à connaître. Injecté à chaque session par le hook ; après chaque correction de ta part, Claude y ajoute la règle (`- <règle>. Why: <raison>.`) pour ne jamais refaire la même erreur.
- **Skills trouvées au bon moment** : chaque skill maison a des déclencheurs FR/EN (`when_to_use`), et les agents préchargent la skill dont ils suivent le gabarit (`planner` → `create-plan`, `review` → `implementation-review` + `review-code`, `test` → `test-code`, `frontend` → `frontend-design`). `/doctor` estime le coût de la liste des skills, `/context` montre sa taille réelle.
- **Garde-fous** : commits, push, PR et publication demandent toujours ta confirmation.

## Dépendances (optionnelles)

- `python3` — requis par `install.sh` pour créer/fusionner `settings.json`.
- `jq` — requis par le hook `rtk-rewrite` ; `python3` — requis par le hook `guard-secrets` (sans eux, ces hooks ne font rien).
- `rtk` — réécriture de commandes économe en tokens.
- `cmux` — vérification visuelle frontend ; à défaut, Claude in Chrome ou le navigateur intégré.
- Notifications du template : `osascript`/`afplay`, macOS uniquement (exclues ailleurs).

## Skills externes (submodules)

Les skills tierces restent chez leurs auteurs : chaque repo est un submodule léger (`shallow`) dans `vendor/`, et `external-skills.txt` liste les skills à installer (`<nom> <dossier du SKILL.md>`). Ne les édite pas ici.

| Skill | Repo | Rôle |
|---|---|---|
| `frontend-design` | [anthropics/skills](https://github.com/anthropics/skills) | Direction artistique : sujet, typographie, palette, retenue, textes d'interface |
| `webapp-testing` | [anthropics/skills](https://github.com/anthropics/skills) | Tests navigateur Playwright headless, logs console, captures (requiert `pip install playwright && playwright install chromium`) |
| `emil-design-eng` | [emilkowalski/skills](https://github.com/emilkowalski/skills) | Finition des interactions : boutons, popovers, transitions, ressorts |
| `review-animations` | [emilkowalski/skills](https://github.com/emilkowalski/skills) | Revue des animations (durées, courbes, mouvements inutiles) |
| `mobile-native` | [emilkowalski/skills](https://github.com/emilkowalski/skills) | Web app sur téléphone : tap, scroll, zoom des champs, encoche |
| `break-ui` | [emilkowalski/skills](https://github.com/emilkowalski/skills) | Stress-test d'écrans avec des données extrêmes (noms longs, listes vides…) |
| `create-design-md` | [ibelick/ui-skills](https://github.com/ibelick/ui-skills) | Crée/met à jour `DESIGN.md` à partir du code ou d'un site existant |
| `web-design-guidelines` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | Revue accessibilité, formulaires, focus, états (règles récupérées en ligne à chaque usage) |
| `apple-design` | [dickwu/apple-design-skill](https://github.com/dickwu/apple-design-skill) | Revue UI/UX selon les Human Interface Guidelines |
| `resume-builder` | [dabydat/resume-builder-skill](https://github.com/dabydat/resume-builder-skill) | CV et lettres, optimisation ATS |

Ajouter une skill (externe ou maison) : demande-le simplement à Claude — la skill `add-skill` l'évalue (pertinence, doublons, sécurité, licence), l'ajoute au bon endroit, puis lance `./scripts/check.sh` et `./install.sh`. À la main : `git submodule add --depth 1 <url> vendor/<repo>`, une ligne dans `external-skills.txt`, puis `./install.sh`. Mettre à jour :

```bash
git submodule update --remote vendor/<repo>
git add vendor/<repo> && git commit -m "chore: bump <repo>"
```

## Skills optionnelles (`optional/skills/`)

5 skills personnelles non installées par défaut : `asset-research-skill`, `sector-research-skill` (MCP Notion), `content-post`, `content-article`, `content-weekly` (guides dans `~/Documents/ObsidianMemory/Content Vault/guides/`). Pour en activer une : `cp -R optional/skills/<nom> .claude/skills/` puis `./install.sh`.

## Utiliser la config dans un projet

Installée globalement, elle s'applique déjà à tous tes projets ; il suffit d'y laisser Claude créer `lessons.md` au fil des corrections. Pour la versionner *dans* un repo (équipe, variante figée), copie `.claude/agents`, `.claude/skills`, `.claude/hooks` et `dev-harness.md` dans le projet, et ajoute `@dev-harness.md` à son `CLAUDE.md`. Dans un `.claude/settings.json` projet, remplace `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` par `$CLAUDE_PROJECT_DIR/.claude` dans les chemins de hooks. La version projet a priorité sur la globale.

## Modifier la config

- La source de vérité est ce repo : édite, puis `./scripts/check.sh` (frontmatter, chemins en dur, JSON, syntaxe bash, idempotence d'`install.sh`). La CI GitHub Actions le rejoue et teste `install.ps1` sous Windows.
- `simplify-code` porte ce nom pour ne pas entrer en collision avec la skill intégrée `simplify`.

## Désinstallation

Supprime les symlinks/copies dans `~/.claude/agents`, `~/.claude/skills`, `~/.claude/hooks/` et `~/.claude/dev-harness.md`, puis retire la section `## Dev Harness` de `~/.claude/CLAUDE.md`.
