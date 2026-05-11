# Image-First Video Workflow

这个流程参考 `gpt-image-2-codex-video-workflow` 的核心思路：先用图片模型把每个镜头的构图、主体位置、光线、留白和视觉层次定下来，再交给视频模型做运动。

## 为什么这样做

直接 T2V 很容易出现两个问题：

- 视频模型把主体、背景、镜头语言一起发散，第一帧不稳定。
- 短视频需要多个镜头一致，单靠文字 prompt 很难保持视觉连续。

Image-first 的目标是把最大的不确定性前移到静帧阶段。图片生成更便宜、更快、更容易挑选，选中构图后再做 I2V 或云端视频生成。

## 本机推荐链路

1. 写一个 `shot_list.json`，每个镜头包含 `image_prompt` 和 `video_prompt`。
2. 用 APIMart `gpt-image-2` 生成 storyboard frame。
3. 人眼挑选或替换不合格构图图。
4. 用 Wan2GP I2V 生成 5 秒本地镜头，或用 APIMart Seedance 2.0 生成 4-15 秒云端镜头。
5. 用 ffmpeg 拼接、加音乐、旁白和字幕。

## 时长策略

当前本机实测的 2 秒视频是验证模型用的 smoke test，不是生产上限。

Wan2GP 14B:

- `33 frames / 16fps = 2.06s`: 只适合快速验通。
- `81 frames / 16fps = 5.06s`: 推荐默认镜头长度。
- `161 frames / 16fps = 10.06s`: 可用于慢动作、氛围镜头，但成本更高。
- 更长：用 sliding window 或多镜头拼接，不建议单镜头硬拉 30 秒。

LTX Desktop:

- 540p 支持 5/6/8/10/20 秒档位。
- 720p 支持 5/6/8/10 秒。
- 1080p 本机更适合作为 5 秒高价值镜头。

APIMart Seedance 2.0:

- 单镜头建议 4-15 秒。
- 适合把 GPT Image2 构图图直接转成更长、更完整的云端视频镜头。
- 适合先快速验证成片节奏，再决定哪些镜头回到本地 Wan2GP/LTX 做低成本迭代。

短视频成片建议：

- 15 秒：3 个 5 秒镜头，或 5 个 3 秒镜头。
- 30 秒：6 个 5 秒镜头。
- 45 秒：8-12 个 3-6 秒镜头。
- 60 秒：8-12 个 5-8 秒镜头，优先用多镜头剪辑，不靠单条长生成。

## 镜头字段

每个镜头至少包含：

```json
{
  "id": "shot_01",
  "title": "Hero product reveal",
  "duration_seconds": 5,
  "image_prompt": "16:9 storyboard frame...",
  "video_prompt": "The camera slowly pushes in...",
  "negative_prompt": "subtitles, watermark, text artifacts",
  "seed": 260101
}
```

## 目录约定

默认项目目录：

```text
F:\AI-Video-Workspace\projects\<project_name>\
  shot_list.json
  storyboards\
  wan2gp_queue.json
  videos\
  seedance_videos\
  manifest.md
```

## 脚本入口

创建项目骨架：

```powershell
.\scripts\New-ImageFirstProject.ps1 -ProjectName demo_product
```

生成构图图：

```powershell
.\scripts\Invoke-ApimartImageStoryboard.ps1 -ProjectDir F:\AI-Video-Workspace\projects\demo_product
```

生成 Wan2GP I2V 队列：

```powershell
.\scripts\New-Wan2GPI2VQueue.ps1 -ProjectDir F:\AI-Video-Workspace\projects\demo_product
```

用 Wan2GP 跑视频：

```powershell
.\scripts\Invoke-Wan2GPQueue.ps1 -ProjectDir F:\AI-Video-Workspace\projects\demo_product
```

用 Seedance 2.0 跑云端视频：

```powershell
.\scripts\Invoke-ApimartSeedanceVideo.ps1 -ProjectDir F:\AI-Video-Workspace\projects\demo_product
```

## APIMart 设置

APIMart 当前官方目录确认有 `gpt-image-2` 和 `doubao-seedance-2.0`。

相关端点：

```text
POST https://api.apimart.ai/v1/images/generations
POST https://api.apimart.ai/v1/uploads/images
POST https://api.apimart.ai/v1/videos/generations
GET  https://api.apimart.ai/v1/tasks/{task_id}
```

本机需要先设置：

```powershell
[Environment]::SetEnvironmentVariable("APIMART_API_KEY", "你的key", "User")
```

重新打开 PowerShell 后再运行 storyboard 或 Seedance 脚本。

## 构图图规则

- 用 16:9 横屏构图，方便 Wan2GP 当前低分辨率测试。
- 构图图尽量少放文字，最终字幕和标题应在剪辑或 HTML 层完成。
- 产品、人物、场景的主位置必须明确。
- 给字幕和 CTA 留负空间，不要让主体占满画面。
- 每个镜头只描述一个运动，不要写成剧情小说。

## 视频 Prompt 规则

I2V 的 prompt 应该描述“这张图怎么动”，而不是重新描述整个世界。

好：

```text
Starting from the provided storyboard image, the camera slowly pushes in while warm steam rises from the mug, subtle highlights move across the matte surface, realistic product commercial motion, no text, no watermark.
```

差：

```text
Create a whole advertisement about a mug, then show a person, then show a kitchen, then show a city...
```

## 当前限制

- 如果没有 `APIMART_API_KEY`，脚本只能生成项目骨架和 Wan2GP 队列，不能自动出构图图或 Seedance 视频。
- Wan2GP I2V 需要对应 I2V 权重；T2V 权重不能完全替代 I2V。
- Seedance 2.0 是云端通道，速度和质量更适合快速成片，但成本取决于 APIMart 账户。
- 长视频不要依赖单次长生成，先做多镜头拼接。
