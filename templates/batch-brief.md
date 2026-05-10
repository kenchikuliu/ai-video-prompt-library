# Batch Brief Template

复制下面模板，为一个产品/主题生成 10-30 条短视频。

```text
项目名称:
平台: TikTok / YouTube Shorts / Instagram Reels / Bilibili / 小红书
目标: 播放 / 关注 / 点击 / 询盘 / 转化
受众:
产品/主题:
核心痛点:
核心好处:
不能说的内容:
视觉风格:
账号人设:
视频长度:
生成模型: Wan2GP 14B / Wan2GP 1.3B / LTX 2.3

请生成:
1. 10 个不同角度
2. 每个角度 1 个 3 秒 hook
3. 每条视频拆成 3-5 个镜头
4. 每个镜头给 Wan2GP 英文 prompt
5. 其中 2 个关键镜头额外给 LTX 详细 prompt
6. 给剪辑顺序和屏幕文字建议
7. 标注高风险/需要避免的说法
```

## 镜头表格式

| clip | duration | purpose | model | prompt | notes |
| --- | --- | --- | --- | --- | --- |
| 1 | 3s | hook | Wan2GP 14B | ... | first frame must be strong |
| 2 | 4s | demo | Wan2GP 14B | ... | show the product clearly |
| 3 | 5s | result | LTX 2.3 | ... | key shot |

## 数据复盘格式

| date | platform | video | hook | views | 3s hold | completion | clicks | saves | comments | decision |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

