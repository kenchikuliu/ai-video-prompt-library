param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectDir,

  [string]$Model = "gpt-image-2",
  [string]$Size = "16:9",
  [string]$BaseUrl = "https://api.apimart.ai/v1",
  [int]$PollSeconds = 5,
  [int]$TimeoutSeconds = 900,
  [switch]$Overwrite
)

$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Invoke-ApimartJson {
  param(
    [string]$Method,
    [string]$Uri,
    [hashtable]$Headers,
    [object]$Body = $null
  )
  if ($null -eq $Body) {
    return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers
  }
  $json = $Body | ConvertTo-Json -Depth 20
  return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers -ContentType "application/json" -Body $json
}

function Find-TaskId {
  param([object]$Response)
  foreach ($path in @(
    @("data", "task_id"),
    @("task_id"),
    @("id")
  )) {
    $cur = $Response
    $ok = $true
    foreach ($key in $path) {
      if ($null -eq $cur.PSObject.Properties[$key]) { $ok = $false; break }
      $cur = $cur.$key
    }
    if ($ok -and $cur) { return [string]$cur }
  }
  if ($Response.data -is [array] -and $Response.data.Count -gt 0 -and $Response.data[0].task_id) {
    return [string]$Response.data[0].task_id
  }
  return ""
}

function Find-ImageUrl {
  param([object]$Node)
  if ($null -eq $Node) { return "" }
  if ($Node -is [string]) {
    if ($Node -match "^https?://") { return $Node }
    return ""
  }
  if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [string])) {
    foreach ($item in $Node) {
      $found = Find-ImageUrl $item
      if ($found) { return $found }
    }
    return ""
  }
  foreach ($prop in $Node.PSObject.Properties) {
    if ($prop.Name -in @("url", "image_url", "output_url")) {
      $found = Find-ImageUrl $prop.Value
      if ($found) { return $found }
    }
  }
  foreach ($prop in $Node.PSObject.Properties) {
    $found = Find-ImageUrl $prop.Value
    if ($found) { return $found }
  }
  return ""
}

$apiKey = $env:APIMART_API_KEY
if (!$apiKey) {
  throw "APIMART_API_KEY is missing. Set it first, then reopen PowerShell."
}

$shotListPath = Join-Path $ProjectDir "shot_list.json"
if (!(Test-Path -LiteralPath $shotListPath)) {
  throw "shot_list.json not found: $shotListPath"
}

$storyboardDir = Join-Path $ProjectDir "storyboards"
$logDir = Join-Path $ProjectDir "logs"
New-Item -ItemType Directory -Force -Path $storyboardDir, $logDir | Out-Null

$headers = @{ Authorization = "Bearer $apiKey" }
$shots = Get-Content -Raw -LiteralPath $shotListPath | ConvertFrom-Json

foreach ($shot in $shots) {
  $id = [string]$shot.id
  if (!$id) { throw "Every shot needs an id." }
  $outFile = Join-Path $storyboardDir "$id.png"
  if ((Test-Path -LiteralPath $outFile) -and -not $Overwrite) {
    Write-Host "skip existing storyboard: $outFile"
    continue
  }

  $prompt = [string]$shot.image_prompt
  if (!$prompt) { throw "$id is missing image_prompt." }

  Write-Host "submit storyboard: $id"
  $body = @{
    model = $Model
    prompt = $prompt
    size = $Size
  }
  $response = Invoke-ApimartJson -Method Post -Uri "$BaseUrl/images/generations" -Headers $headers -Body $body
  [System.IO.File]::WriteAllText((Join-Path $logDir "$id.image.submit.json"), ($response | ConvertTo-Json -Depth 20), $Utf8NoBom)

  $taskId = Find-TaskId $response
  $imageUrl = ""
  if (!$taskId) {
    $imageUrl = Find-ImageUrl $response
    if (!$imageUrl) { throw "No task_id or image URL found for $id." }
  } else {
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    do {
      Start-Sleep -Seconds $PollSeconds
      $result = Invoke-ApimartJson -Method Get -Uri "$BaseUrl/tasks/$taskId" -Headers $headers
      [System.IO.File]::WriteAllText((Join-Path $logDir "$id.image.result.json"), ($result | ConvertTo-Json -Depth 20), $Utf8NoBom)
      $status = [string]($result.status)
      if (!$status -and $result.data) { $status = [string]$result.data.status }
      Write-Host "  $id task $taskId status: $status"
      if ($status -match "fail|error|cancel") { throw "Image task failed for ${id}: $status" }
      $imageUrl = Find-ImageUrl $result
      if ($imageUrl -and ($status -match "success|completed|succeeded|done|finished" -or $result.result -or $result.data)) { break }
    } while ((Get-Date) -lt $deadline)
    if (!$imageUrl) { throw "Timed out waiting for image URL for $id." }
  }

  Invoke-WebRequest -Uri $imageUrl -OutFile $outFile
  Write-Host "saved storyboard: $outFile"
}
