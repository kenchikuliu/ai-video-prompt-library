param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectDir,

  [string]$Wan2GPDir = "F:\Wan2GP",
  [string]$QueueFile = "",
  [string]$OutputSubdir = "videos",
  [string]$Attention = "sdpa",
  [int]$Profile = 4,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if (!$QueueFile) {
  $QueueFile = Join-Path $ProjectDir "wan2gp_queue.json"
}
if (!(Test-Path -LiteralPath $QueueFile)) {
  throw "Queue file not found: $QueueFile"
}

$python = Join-Path $Wan2GPDir "env_uv\Scripts\python.exe"
$wgp = Join-Path $Wan2GPDir "wgp.py"
if (!(Test-Path -LiteralPath $python)) { throw "Python not found: $python" }
if (!(Test-Path -LiteralPath $wgp)) { throw "wgp.py not found: $wgp" }

$outputDir = Join-Path $ProjectDir $OutputSubdir
$logDir = Join-Path $ProjectDir "logs"
New-Item -ItemType Directory -Force -Path $outputDir, $logDir | Out-Null

$args = @("-u", "wgp.py", "--process", $QueueFile, "--output-dir", $outputDir, "--attention", $Attention, "--profile", "$Profile")
if ($DryRun) { $args += "--dry-run" }

$logFile = Join-Path $logDir ("wan2gp_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log")
Write-Host "Running: $python $($args -join ' ')"
Write-Host "Log: $logFile"

Push-Location $Wan2GPDir
try {
  & $python @args 2>&1 | Tee-Object -FilePath $logFile
  if ($LASTEXITCODE -ne 0) {
    throw "Wan2GP exited with code $LASTEXITCODE"
  }
} finally {
  Pop-Location
}

Write-Host "Output: $outputDir"
