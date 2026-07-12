# Installe la config starter Claude Code dans %USERPROFILE%\.claude (ou $env:CLAUDE_CONFIG_DIR).
#
# Parameters
#   -Mode : "copy" (defaut, recommande sur Windows) ou "link" (symlinks ;
#           necessite le mode developpeur Windows ou une console administrateur).
# What it does
#   Copie/symlinke les agents, skills et dev-harness.md dans la config globale
#   Claude Code, ajoute l'import @dev-harness.md au CLAUDE.md global, et cree ou
#   fusionne les permissions de settings.json. Les hooks du template (rtk,
#   notifications) ne sont PAS installes : ils reposent sur bash/osascript,
#   specifiques a macOS. Les fichiers existants remplaces sont sauvegardes dans
#   backups\. Idempotent : relancable sans effet de bord.
# Output
#   Journal des actions ; s'arrete a la premiere erreur.

[CmdletBinding()]
param(
  [ValidateSet("copy", "link")]
  [string]$Mode = "copy"
)

$ErrorActionPreference = "Stop"

$RepoDir = $PSScriptRoot
$Dest = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE ".claude" }
$BackupDir = Join-Path $Dest ("backups\claude-starter-" + (Get-Date -Format "yyyyMMdd-HHmmss"))

New-Item -ItemType Directory -Force -Path (Join-Path $Dest "agents") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $Dest "skills") | Out-Null

function Place([string]$Src, [string]$Dst) {
  if (Test-Path $Dst) {
    $item = Get-Item $Dst -Force
    if (-not $item.LinkType) {
      New-Item -ItemType Directory -Force -Path $script:BackupDir | Out-Null
      Move-Item $Dst $script:BackupDir
      Write-Host "  sauvegarde: $Dst -> $script:BackupDir"
    }
    elseif ($item.PSIsContainer) {
      # Supprime le lien de dossier sans suivre la cible (Remove-Item -Recurse
      # peut suivre les symlinks sous PowerShell 5.1).
      [System.IO.Directory]::Delete($Dst, $false)
    }
    else {
      [System.IO.File]::Delete($Dst)
    }
  }
  if ($Mode -eq "copy") {
    Copy-Item $Src $Dst -Recurse
  }
  else {
    try {
      New-Item -ItemType SymbolicLink -Path $Dst -Target $Src | Out-Null
    }
    catch {
      Write-Error ("Creation de symlink impossible ($Dst). Active le mode developpeur Windows, " +
        "lance en administrateur, ou utilise: .\install.ps1 -Mode copy")
    }
  }
}

Write-Host "== Agents -> $(Join-Path $Dest 'agents')"
Get-ChildItem (Join-Path $RepoDir ".claude\agents") -Filter *.md | ForEach-Object {
  Place $_.FullName (Join-Path $Dest "agents\$($_.Name)")
}

Write-Host "== Skills -> $(Join-Path $Dest 'skills')"
Get-ChildItem (Join-Path $RepoDir ".claude\skills") -Directory | ForEach-Object {
  Place $_.FullName (Join-Path $Dest "skills\$($_.Name)")
}

Write-Host "== Harnais -> $(Join-Path $Dest 'dev-harness.md')"
Place (Join-Path $RepoDir "dev-harness.md") (Join-Path $Dest "dev-harness.md")

Write-Host "== Import dans $(Join-Path $Dest 'CLAUDE.md')"
$ClaudeMd = Join-Path $Dest "CLAUDE.md"
if (-not (Test-Path $ClaudeMd)) {
  Set-Content -Path $ClaudeMd -Value "# CLAUDE.md`n`n## Dev Harness`n`n@dev-harness.md" -Encoding UTF8
  Write-Host "  CLAUDE.md cree avec l'import @dev-harness.md"
}
elseif (-not (Select-String -Path $ClaudeMd -Pattern "@dev-harness.md" -Quiet)) {
  Add-Content -Path $ClaudeMd -Value "`n## Dev Harness`n`n@dev-harness.md" -Encoding UTF8
  Write-Host "  import @dev-harness.md ajoute"
}
else {
  Write-Host "  import deja present"
}

Write-Host "== Settings (permissions uniquement ; hooks du template = macOS, ignores)"
$SettingsPath = Join-Path $Dest "settings.json"
$Template = Get-Content (Join-Path $RepoDir "settings.template.json") -Raw | ConvertFrom-Json
if (-not (Test-Path $SettingsPath)) {
  @{ permissions = @{ allow = $Template.permissions.allow } } |
    ConvertTo-Json -Depth 10 | Set-Content -Path $SettingsPath -Encoding UTF8
  Write-Host "  settings.json cree avec les permissions du template"
}
else {
  $Settings = Get-Content $SettingsPath -Raw | ConvertFrom-Json
  if (-not $Settings.PSObject.Properties["permissions"]) {
    $Settings | Add-Member -NotePropertyName permissions -NotePropertyValue ([pscustomobject]@{ allow = @() })
  }
  if (-not $Settings.permissions.PSObject.Properties["allow"]) {
    $Settings.permissions | Add-Member -NotePropertyName allow -NotePropertyValue @()
  }
  $Added = 0
  foreach ($Rule in $Template.permissions.allow) {
    if ($Settings.permissions.allow -notcontains $Rule) {
      $Settings.permissions.allow = @($Settings.permissions.allow) + $Rule
      $Added++
    }
  }
  $Settings | ConvertTo-Json -Depth 100 | Set-Content -Path $SettingsPath -Encoding UTF8
  Write-Host "  permissions fusionnees ($Added regle(s) ajoutee(s)) ; hooks non modifies"
}

Write-Host ""
Write-Host "Installation terminee ($Mode). Redemarre les sessions Claude Code pour appliquer."
