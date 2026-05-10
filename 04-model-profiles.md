# Model Profiles

## Wan2GP 1.3B

用途:

- 快速试 prompt。
- 找画面方向、动作方向、构图。
- 不作为最终高质量主力，除非内容很简单。

建议:

- 短镜头: 17-49 帧。
- 低分辨率先试。
- 一个 prompt 一个明确动作。

## Wan2GP Wan2.2 14B

用途:

- 当前本机主力。
- 产品镜头、电影化镜头、短剧情镜头。
- 批量生成多个 3-6 秒片段，再剪辑。

已下载:

- `F:\Wan2GP\ckpts\wan2.2_text2video_14B_high_quanto_mbf16_int8.safetensors`
- `F:\Wan2GP\ckpts\wan2.2_text2video_14B_low_quanto_mbf16_int8.safetensors`

建议:

- 先用 17-81 帧找方向。
- 需要连续短片时，拆成镜头 1、镜头 2、镜头 3。
- 复杂运动用更短 prompt，不要把剧情写成小说。

## LTX Desktop LTX 2.3 Fast

用途:

- 更完整的 5-20 秒镜头。
- 画面质感、氛围、产品大特写、形象片段。
- 少量高价值镜头。

已下载:

- `F:\LTXDesktop\models\ltx-2.3-22b-distilled.safetensors`
- `F:\LTXDesktop\models\ltx-2.3-spatial-upscaler-x2-1.0.safetensors`
- `F:\LTXDesktop\models\gemma-3-12b-it-qat-q4_0-unquantized`

本机实测:

- 540p / 5 秒 / 24fps 可生成。
- RTX 3090 上单条 5 秒约 22 分钟级别。

建议:

- 先用 Wan2GP 或图片确认构图，再让 LTX 做终稿镜头。
- 适合更长、更细的 prompt。
- 不适合大量试错。

## 成片策略

短视频成片不要依赖单次长生成：

- 15 秒视频: 3-5 个镜头。
- 30 秒视频: 5-8 个镜头。
- 45 秒视频: 8-12 个镜头。

每个镜头单独生成、挑选、剪辑，质量通常比一次生成整条更稳。

