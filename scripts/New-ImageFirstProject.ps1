param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectName,

  [string]$Root = "F:\AI-Video-Workspace\projects",
  [string]$ShotListTemplate = "",
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Copy-JsonTemplate {
  param([string]$Source, [string]$Destination)
  if (!(Test-Path -LiteralPath $Source)) {
    throw "Template not found: $Source"
  }
  Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

$projectDir = Join-Path $Root $ProjectName
if ((Test-Path -LiteralPath $projectDir) -and -not $Force) {
  throw "Project already exists: $projectDir. Use -Force to reuse it."
}

New-Item -ItemType Directory -Force -Path $projectDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $projectDir "storyboards") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $projectDir "videos") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $projectDir "logs") | Out-Null

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$defaultTemplate = Join-Path $repoRoot "examples\image-first-shot-list.json"
$template = if ($ShotListTemplate) { $ShotListTemplate } else { $defaultTemplate }
$shotList = Join-Path $projectDir "shot_list.json"
Copy-JsonTemplate -Source $template -Destination $shotList

$manifest = Join-Path $projectDir "manifest.md"
if (!(Test-Path -LiteralPath $manifest) -or $Force) {
  [System.IO.File]::WriteAllText($manifest, @"
# $ProjectName

Created: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Workflow:

1. Generate storyboard images into storyboards\.
2. Build wan2gp_queue.json.
3. Render I2V clips into videos\.

"@, $Utf8NoBom)
}

[pscustomobject]@{
  ProjectDir = $projectDir
  ShotList = $shotList
  Storyboards = Join-Path $projectDir "storyboards"
  Videos = Join-Path $projectDir "videos"
  Manifest = $manifest
}
