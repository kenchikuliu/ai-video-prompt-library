# Wan2GP I2V Template

Use this after a storyboard image has already fixed the composition.

## Prompt Shape

```text
Starting from the provided storyboard image, [ONE MOTION], [CAMERA MOVEMENT], preserve the subject identity, composition, lighting, color palette, and background from the image, realistic temporal motion, no subtitles, no on-screen text, no watermark.
```

## Product I2V

```text
Starting from the provided storyboard image, the camera slowly pushes in while [PRODUCT-SPECIFIC MOTION], preserve the product shape, material, color, packaging, lighting, and clean background from the image, premium product commercial motion, shallow depth of field, no subtitles, no text, no watermark, no distorted packaging.
```

## UGC I2V

```text
Starting from the provided storyboard image, [PERSON/HANDS] performs one simple natural action with [PRODUCT], subtle handheld camera movement, preserve the room layout and product appearance from the image, authentic social media UGC motion, no subtitles, no watermark, no distorted hands, no extra fingers.
```

## Cinematic B-Roll I2V

```text
Starting from the provided storyboard image, [SUBJECT ACTION OR ENVIRONMENT MOTION], camera [pushes in / tracks sideways / slowly orbits], preserve the cinematic lighting and composition from the image, realistic motion, no subtitles, no text, no watermark.
```

## Negative Prompt

```text
subtitles, on-screen text, watermark, logo, text artifacts, distorted hands, extra fingers, deformed face, extra limbs, duplicated subject, flickering, abrupt scene cut, low quality
```

## Wan2GP JSON Fields

Typical 5-second I2V task:

```json
{
  "model_type": "i2v_2_2",
  "prompt": "Starting from the provided storyboard image...",
  "negative_prompt": "subtitles, on-screen text, watermark...",
  "image_mode": 0,
  "image_prompt_type": "S",
  "image_start": "F:\\AI-Video-Workspace\\projects\\demo\\storyboards\\shot_01.png",
  "resolution": "512x288",
  "video_length": 81,
  "num_inference_steps": 4,
  "guidance_phases": 2,
  "guidance_scale": 3.5,
  "guidance2_scale": 3.5,
  "flow_shift": 5,
  "seed": 260101
}
```
