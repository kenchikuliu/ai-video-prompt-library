param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectDir,

  [string]$VideosDir = "",
  [string]$OutFile = "",
  [string]$Ffmpeg = "ffmpeg"
)

$ErrorActionPreference = "Stop"

if (!$VideosDir) { $VideosDir = Join-Path $ProjectDir "videos" }
if (!$OutFile) { $OutFile = Join-Path $ProjectDir "final_edit.mp4" }
if (!(Test-Path -LiteralPath $VideosDir)) { throw "Videos dir not found: $VideosDir" }

$files = Get-ChildItem -LiteralPath $VideosDir -File |
  Where-Object { $_.Extension -in @(".mp4", ".mov", ".mkv") } |
  Sort-Object LastWriteTime
if ($files.Count -eq 0) { throw "No videos found in $VideosDir" }

$listFile = Join-Path $ProjectDir "concat_list.txt"
$lines = foreach ($file in $files) {
  $escaped = $file.FullName.Replace("'", "'\''")
  "file '$escaped'"
}
$lines | Set-Content -LiteralPath $listFile -Encoding ASCII

& $Ffmpeg -y -f concat -safe 0 -i $listFile -c copy $OutFile
if ($LASTEXITCODE -ne 0) {
  throw "ffmpeg concat failed with code $LASTEXITCODE"
}

Write-Host $OutFile
