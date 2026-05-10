# AI Video Prompt Library

这是给本机 Wan2GP + LTX Desktop 使用的自有短视频提示词库。

目标不是收藏一堆原始 prompt，而是把外部资源整理成一套可执行的本地生产流程：

- 用 Wan2GP 快速批量生成 3-6 秒镜头。
- 用 LTX Desktop 生成更完整的 5-20 秒镜头或 LTX 风格片段。
- 用统一的镜头语言、广告脚本、产品展示、剧情短片模板来批量测试。
- 每条短视频拆成多个短镜头，而不是一次硬生成 30-60 秒。

## 本机入口

- Wan2GP: http://127.0.0.1:7860
- LTX Desktop: 桌面快捷方式 `LTX Desktop`
- LTX 测试后端: http://127.0.0.1:41955

## 推荐生产方式

1. 先用 `02-short-video-production.md` 写短视频 brief。
2. 用 `03-prompt-framework.md` 把想法改成镜头 prompt。
3. 用 `templates/wan2gp-t2v.md` 生成快速镜头。
4. 用 `templates/ltx-desktop.md` 生成更长、更完整的镜头。
5. 用 `prompt-bank.md` 选类别，批量改主题、主体、场景和产品。
6. 用剪辑软件拼成 15-45 秒短视频。

## 当前实测建议

Wan2GP:

- 1.3B 适合快速试方向。
- Wan2.2 14B 适合主力出片。
- 推荐先做 512x288 或接近低分辨率小样，确认方向后再提高规格。
- 常规短镜头建议 17-81 帧；更长可以用 sliding window，但成本和不稳定性上升。

LTX Desktop:

- 已验证 540p / 5s 可跑。
- 本机 RTX 3090 上 5 秒约 22 分钟级别。
- 更适合少量高价值镜头，不适合大量试错。

## 目录

- `01-sources.md`: 外部来源索引和使用原则。
- `02-short-video-production.md`: 短视频生产流程。
- `03-prompt-framework.md`: 我们自己的视频 prompt 结构。
- `04-model-profiles.md`: Wan2GP/LTX 本机模型使用建议。
- `prompt-bank.md`: 可直接改写的提示词库。
- `templates/wan2gp-t2v.md`: Wan2GP 模板。
- `templates/ltx-desktop.md`: LTX Desktop 模板。
- `templates/batch-brief.md`: 批量生产 brief 模板。

