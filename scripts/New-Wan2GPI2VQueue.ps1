param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectDir,

  [string]$Resolution = "512x288",
  [int]$Frames = 81,
  [int]$Steps = 4,
  [string]$ModelType = "i2v_2_2",
  [switch]$AllowMissingStoryboards
)

$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$shotListPath = Join-Path $ProjectDir "shot_list.json"
if (!(Test-Path -LiteralPath $shotListPath)) {
  throw "shot_list.json not found: $shotListPath"
}

$storyboardDir = Join-Path $ProjectDir "storyboards"
$queuePath = Join-Path $ProjectDir "wan2gp_queue.json"
$shots = Get-Content -Raw -LiteralPath $shotListPath | ConvertFrom-Json
$tasks = @()

foreach ($shot in $shots) {
  $id = [string]$shot.id
  if (!$id) { throw "Every shot needs an id." }

  $imagePath = Join-Path $storyboardDir "$id.png"
  if (!(Test-Path -LiteralPath $imagePath)) {
    if ($AllowMissingStoryboards) {
      Write-Warning "missing storyboard for $id; queue will still reference $imagePath"
    } else {
      throw "Storyboard missing for ${id}: $imagePath"
    }
  }

  $negative = [string]$shot.negative_prompt
  if (!$negative) {
    $negative = "subtitles, on-screen text, watermark, logo, text artifacts, distorted hands, extra fingers, deformed face, extra limbs, duplicated subject, flickering, abrupt scene cut, low quality"
  }

  $durationFrames = $Frames
  if ($shot.duration_seconds) {
    $durationFrames = [int]([math]::Round(([double]$shot.duration_seconds * 16)))
    $durationFrames = [math]::Max(17, $durationFrames)
    if (($durationFrames - 1) % 4 -ne 0) {
      $durationFrames = $durationFrames + (4 - (($durationFrames - 1) % 4))
    }
  }

  $tasks += [ordered]@{
    model_type = $ModelType
    prompt = [string]$shot.video_prompt
    negative_prompt = $negative
    image_mode = 0
    image_prompt_type = "S"
    image_start = $imagePath
    video_prompt_type = ""
    resolution = $Resolution
    video_length = $durationFrames
    num_inference_steps = $Steps
    guidance_phases = 2
    guidance_scale = 3.5
    guidance2_scale = 3.5
    flow_shift = 5
    seed = [int]$shot.seed
    repeat_generation = 1
    activated_loras = @()
    loras_multipliers = ""
    sample_solver = "unipc"
    MMAudio_setting = 0
    prompt_enhancer = ""
  }
}

[System.IO.File]::WriteAllText($queuePath, ($tasks | ConvertTo-Json -Depth 20), $Utf8NoBom)
Write-Host $queuePath
