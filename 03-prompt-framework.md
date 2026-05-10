# Prompt Framework

这是我们自己的视频 prompt 结构，适配 Wan2GP 和 LTX Desktop。

## 核心公式

中文构思:

`主体 + 场景 + 动作 + 镜头 + 光线 + 风格 + 细节 + 约束`

英文生成:

`Subject, setting, action, camera movement, lighting, visual style, atmosphere, details, quality constraints.`

## 字段说明

Subject:

- 谁或什么是画面中心。
- 写清年龄、服装、材质、颜色、形状、产品特征。

Setting:

- 场景位置、时间、环境元素。
- 不要只写 "city" 或 "room"，要写具体到街角、桌面、厨房台面、雨夜车窗。

Action:

- 3-6 秒内发生的明确动作。
- 少写复杂剧情，多写单一动作的开始、变化、结束。

Camera:

- shot type: close-up, medium shot, wide shot, macro shot, overhead shot。
- movement: slow dolly in, handheld follow, orbit shot, push-in, pan left, tilt down。
- 对 Wan2GP 建议一次只写一个主要镜头运动。

Lighting:

- golden hour, soft window light, neon reflections, backlight, studio softbox, moody low-key lighting。

Style:

- cinematic, documentary, product commercial, realistic, cozy lifestyle, clean studio, handheld UGC。

Details:

- 材质、反射、表情、微动作、背景动效。
- 对产品视频尤其重要。

Constraints:

- no text, no subtitles, no watermark, no logo unless requested。
- avoid extra fingers, distorted face, flickering, duplicated objects。

## Wan2GP 写法

Wan 更适合短而清晰的运动指令：

```text
A cinematic close-up of a stainless steel insulated coffee mug on a wooden desk, morning sunlight through blinds, steam slowly rising, camera slowly pushes in, shallow depth of field, realistic reflections, clean product commercial style, no text, no watermark.
```

少做:

- 同一段里塞 5 个镜头变化。
- 同时要求复杂角色、台词、字幕、产品演示、转场。

## LTX 写法

LTX 可以写更长的场景描述，尤其适合 5-20 秒镜头：

```text
A warm lifestyle product video in a small sunlit kitchen. A young professional places a compact meal-prep container on the counter, opens the lid, and fresh colorful food is revealed inside. The camera begins with a medium shot, then slowly pushes into a close-up of the texture and steam. Soft morning window light, natural handheld movement, realistic home atmosphere, subtle reflections on the countertop, clean commercial style, no subtitles, no on-screen text.
```

## 负面约束库

通用:

```text
no subtitles, no on-screen text, no watermark, no logo, no distorted hands, no deformed face, no extra limbs, no flickering, no duplicate subjects, no low quality, no abrupt scene cut
```

产品:

```text
keep the product shape consistent, readable silhouette, no brand logo, no fake text, no melted edges, no distorted packaging
```

人物:

```text
natural face, consistent clothing, natural hands, realistic skin texture, no uncanny expression, no duplicated person
```

竖屏短视频:

```text
vertical composition, subject centered, clean background, strong first frame, mobile-friendly framing
```

