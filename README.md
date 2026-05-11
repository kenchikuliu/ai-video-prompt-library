# AI Video Prompt Library

这是给本机 Wan2GP + LTX Desktop 使用的短视频提示词和生产流程库。
目标不是收藏一堆原始 prompt，而是把外部资源整理成一套可执行的本地视频生产流程：

- 用 APIMart `gpt-image-2` 先生成每个镜头的构图图。
- 用 Wan2GP / LTX Desktop 把构图图转成 3-6 秒本地短镜头。
- 用 APIMart Seedance 2.0 把同一批构图图转成 4-15 秒云端镜头。
- 用统一的镜头语言、广告脚本、产品展示、剧情短片模板来批量测试。
- 每条短视频拆成多个短镜头，而不是一次硬生成 30-60 秒。

## 本机入口

- Wan2GP: `http://127.0.0.1:7860`
- LTX Desktop: 桌面快捷方式 `LTX Desktop`
- 大文件工作盘: `F:\`

## 推荐生产方式

1. 用 `02-short-video-production.md` 写短视频 brief。
2. 用 `03-prompt-framework.md` 把想法改成镜头 prompt。
3. 用 `05-image-first-workflow.md` 先生成每个镜头的构图图。
4. 用 `templates/wan2gp-i2v.md` 或 `templates/wan2gp-t2v.md` 生成短镜头。
5. 需要更长、更快的云端镜头时，用 `templates/seedance-apimart.md` 和 Seedance 2.0。
6. 用 `prompt-bank.md` 选类别，批量改主题、主体、场景和产品。
7. 把 3-10 秒镜头剪成 15-60 秒成片。

## 当前实测建议

Wan2GP:

- 1.3B 适合快速试方向。
- Wan2.2 14B 适合主力出片。
- 之前的 2 秒视频只是 smoke test：`33 frames / 16fps = 2.06s`。
- 实用默认建议改成 `81 frames / 16fps = 5.06s`。
- `161 frames / 16fps = 10.06s` 可跑，但等待和失败成本明显更高。

LTX Desktop:

- 已验证 540p / 5s 可跑。
- RTX 3090 上单条 5 秒约 22 分钟级别。
- 更适合少量高价值镜头，不适合大批量试错。

## 目录

- `01-sources.md`: 外部来源索引和使用原则。
- `02-short-video-production.md`: 短视频生产流程。
- `03-prompt-framework.md`: 我们自己的视频 prompt 结构。
- `04-model-profiles.md`: Wan2GP/LTX 本机模型使用建议。
- `05-image-first-workflow.md`: 先构图图、再视频的生产流程。
- `prompt-bank.md`: 可直接改写的提示词库。
- `templates/wan2gp-t2v.md`: Wan2GP 文生视频模板。
- `templates/wan2gp-i2v.md`: Wan2GP 图生视频模板。
- `templates/seedance-apimart.md`: APIMart Seedance 2.0 云端视频模板。
- `templates/image-composition.md`: GPT-Image-2 构图图模板。
- `templates/batch-brief.md`: 批量生产 brief 模板。
- `scripts/`: Windows 本地自动化脚本。
