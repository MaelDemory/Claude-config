# Lessons

## Tests d'installation
- Lancer un installeur de test dans une seule commande `CLAUDE_CONFIG_DIR="$T" ./install.sh` (ou `install.ps1`), jamais via un `export` séparé ni après une chaîne `&&` qui peut échouer. Why: un `sed` raté a sauté la création du dossier temporaire et `install.ps1` a réécrit le vrai `~/.claude`.

## Windows / Git Bash
- Dans `PATH`, écrire les chemins en `/c/...`, jamais `C:/...`. Why: le `:` de `C:` coupe l'entrée et le binaire n'est pas trouvé.
- Un chemin passé dans du JSON à un Python natif doit être converti (`cygpath -m`). Why: Git Bash ne convertit que les arguments, pas le contenu de stdin.

## PowerShell
- Initialiser un tableau puis l'assigner (`$X = @(); if (...) { $X = @(...) }`), jamais `$X = if (...) { @(...) }`. Why: `if` en expression déroule un tableau à un élément en objet seul, et `+` échoue ensuite (`op_Addition`).
