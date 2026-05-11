# APIMart Seedance 2.0 Template

Use this when you want a fast cloud video pass from the same image-first shot list.

## Endpoint

```text
POST https://api.apimart.ai/v1/uploads/images
POST https://api.apimart.ai/v1/videos/generations
GET  https://api.apimart.ai/v1/tasks/{task_id}
```

Model:

```text
doubao-seedance-2.0
```

## Prompt Shape

```text
Starting from the provided storyboard image, [ONE MOTION], [CAMERA MOVEMENT], preserve the subject identity, environment, lighting, color palette, and composition, realistic short-film motion, natural pacing, no subtitles, no watermark.
```

## Duration

Seedance 2.0 is the better path when a single cloud-generated shot should be longer than a local 2-5 second smoke test.

Recommended use:

- 4-5 seconds: fast shot tests.
- 8-10 seconds: hero shot or dialogue-lite scene.
- 12-15 seconds: only when the shot has simple motion and a stable subject.

For a 60-second short, still use multiple shots and edit them together.

## Image-First Rule

Generate or select a storyboard frame first, upload that image to APIMart, then call video generation with the uploaded image URL as the first frame. Do not ask Seedance to invent character design, location, and camera language from scratch if consistency matters.

## Negative Prompt

```text
subtitles, captions, watermark, logo, random text, distorted hands, extra fingers, deformed face, extra limbs, flickering, abrupt scene cut, low quality
```
