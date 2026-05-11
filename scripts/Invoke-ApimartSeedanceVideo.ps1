param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectDir,

  [string]$Model = "doubao-seedance-2.0",
  [string]$BaseUrl = "https://api.apimart.ai/v1",
  [int]$DurationSeconds = 5,
  [string]$Resolution = "720p",
  [int]$PollSeconds = 8,
  [int]$TimeoutSeconds = 1800,
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

function Upload-ApimartImage {
  param(
    [string]$Path,
    [hashtable]$Headers,
    [string]$BaseUrl
  )
  $file = Get-Item -LiteralPath $Path
  $form = @{
    file = $file
  }
  $response = Invoke-RestMethod -Method Post -Uri "$BaseUrl/uploads/images" -Headers $Headers -Form $form
  $response | ConvertTo-Json -Depth 20
  foreach ($pathSpec in @(
    @("data", "url"),
    @("url"),
    @("data", "image_url"),
    @("image_url")
  )) {
    $cur = $response
    $ok = $true
    foreach ($key in $pathSpec) {
      if ($null -eq $cur.PSObject.Properties[$key]) { $ok = $false; break }
      $cur = $cur.$key
    }
    if ($ok -and $cur) { return [string]$cur }
  }
  return ""
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

function Find-VideoUrl {
  param([object]$Node)
  if ($null -eq $Node) { return "" }
  if ($Node -is [string]) {
    if ($Node -match "^https?://.*\.(mp4|mov|webm)(\?|$)") { return $Node }
    return ""
  }
  if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [string])) {
    foreach ($item in $Node) {
      $found = Find-VideoUrl $item
      if ($found) { return $found }
    }
    return ""
  }
  foreach ($prop in $Node.PSObject.Properties) {
    if ($prop.Name -in @("url", "video_url", "output_url")) {
      $found = Find-VideoUrl $prop.Value
      if ($found) { return $found }
    }
  }
  foreach ($prop in $Node.PSObject.Properties) {
    $found = Find-VideoUrl $prop.Value
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
$videoDir = Join-Path $ProjectDir "seedance_videos"
$logDir = Join-Path $ProjectDir "logs"
New-Item -ItemType Directory -Force -Path $videoDir, $logDir | Out-Null

$headers = @{ Authorization = "Bearer $apiKey" }
$shots = Get-Content -Raw -LiteralPath $shotListPath | ConvertFrom-Json

foreach ($shot in $shots) {
  $id = [string]$shot.id
  if (!$id) { throw "Every shot needs an id." }
  $imagePath = Join-Path $storyboardDir "$id.png"
  if (!(Test-Path -LiteralPath $imagePath)) {
    throw "Storyboard missing for ${id}: $imagePath"
  }

  $outFile = Join-Path $videoDir "$id.mp4"
  if ((Test-Path -LiteralPath $outFile) -and -not $Overwrite) {
    Write-Host "skip existing video: $outFile"
    continue
  }

  $duration = if ($shot.duration_seconds) { [int]$shot.duration_seconds } else { $DurationSeconds }
  $duration = [Math]::Min(15, [Math]::Max(4, $duration))
  $prompt = [string]$shot.video_prompt
  if (!$prompt) { throw "$id is missing video_prompt." }

  Write-Host "submit Seedance video: $id"
  $imageUrl = Upload-ApimartImage -Path $imagePath -Headers $headers -BaseUrl $BaseUrl
  if (!$imageUrl) { throw "Image upload did not return a URL for ${id}: $imagePath" }
  $body = @{
    model = $Model
    prompt = $prompt
    image_urls = @($imageUrl)
    duration = "$duration"
    resolution = $Resolution
  }
  $response = Invoke-ApimartJson -Method Post -Uri "$BaseUrl/videos/generations" -Headers $headers -Body $body
  [System.IO.File]::WriteAllText((Join-Path $logDir "$id.seedance.submit.json"), ($response | ConvertTo-Json -Depth 20), $Utf8NoBom)

  $taskId = Find-TaskId $response
  $videoUrl = ""
  if (!$taskId) {
    $videoUrl = Find-VideoUrl $response
    if (!$videoUrl) { throw "No task_id or video URL found for $id." }
  } else {
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    do {
      Start-Sleep -Seconds $PollSeconds
      $result = Invoke-ApimartJson -Method Get -Uri "$BaseUrl/tasks/$taskId" -Headers $headers
      [System.IO.File]::WriteAllText((Join-Path $logDir "$id.seedance.result.json"), ($result | ConvertTo-Json -Depth 20), $Utf8NoBom)
      $status = [string]($result.status)
      if (!$status -and $result.data) { $status = [string]$result.data.status }
      Write-Host "  $id task $taskId status: $status"
      if ($status -match "fail|error|cancel") { throw "Seedance task failed for ${id}: $status" }
      $videoUrl = Find-VideoUrl $result
      if ($videoUrl -and ($status -match "success|completed|succeeded|done|finished" -or $result.result -or $result.data)) { break }
    } while ((Get-Date) -lt $deadline)
    if (!$videoUrl) { throw "Timed out waiting for video URL for $id." }
  }

  Invoke-WebRequest -Uri $videoUrl -OutFile $outFile
  Write-Host "saved Seedance video: $outFile"
}
