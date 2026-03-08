# 即刻（Jike）网站自动化技能

[![Midscene](https://img.shields.io/badge/Powered%20by-Midscene-blue)](https://midscenejs.com) [![Bridge Mode](https://img.shields.io/badge/Mode-Bridge-green)](https://midscenejs.com/bridge-mode-by-chrome-extension.html)

## 简介

基于 Midscene Bridge 模式的即刻网站自动化技能集，让 AI Agent 直接操控你的浏览器完成日常操作。无需重新登录，直接复用 Chrome 浏览器的现有登录状态。覆盖浏览、互动、发布等即刻日常使用场景。

## 功能特性

- 浏览关注流和推荐流动态
- 点赞、评论、转发等社交互动
- 发布图文动态
- 关注 / 取关用户和话题
- 搜索用户、话题、内容
- 查看消息通知

## 快速开始

1. **安装 Midscene Chrome 扩展** — 前往 [Chrome Web Store](https://chromewebstore.google.com/detail/midscene/gbldofggpekfghkbmpnmeenijgfhppbf) 安装扩展
2. **打开即刻并登录** — 在 Chrome 中访问 [web.okjike.com](https://web.okjike.com) 并完成登录
3. **启用 Bridge 模式** — 点击扩展图标，切换至 Bridge 模式，确认扩展显示 "Listening"
4. **配置模型环境变量** — 参考下方 [环境变量配置](#环境变量配置) 设置 AI 模型参数
5. **通过 Claude Code 调用技能** — 在 Claude Code 中加载本技能，描述你想执行的操作即可

## 项目结构

```
jike-skills/
├── SKILL.md                      # 主技能文件
└── examples/
    ├── feed-collection.md        # 采集关注流内容
    ├── social-interactions.md    # 批量互动操作
    └── content-creation.md      # 内容创作工作流
```

## 使用场景示例

### 场景 1：每日内容归档

每天采集关注流中感兴趣的内容，将动态标题、链接和摘要整理成笔记，方便后续回顾与分类存档。

### 场景 2：批量互动

针对某个话题下的热门动态批量点赞，或对特定用户的近期内容统一进行评论互动，节省手动操作时间。

### 场景 3：定时发布动态

将预先写好的文字和图片素材交给 Agent，按计划在指定时间发布到即刻，适合内容创作者的批量运营需求。

## 环境变量配置

在项目根目录创建 `.env` 文件，填入以下配置：

```bash
MIDSCENE_MODEL_API_KEY="your-api-key"
MIDSCENE_MODEL_NAME="model-name"
MIDSCENE_MODEL_BASE_URL="https://..."
MIDSCENE_MODEL_FAMILY="family-identifier"
```

## 相关资源

- [Midscene Bridge Mode 文档](https://midscenejs.com/bridge-mode-by-chrome-extension.html)
- [即刻网页版](https://web.okjike.com)

## 注意事项

- 此技能仅供个人使用和学习目的，请勿用于商业或大规模批量操作
- 请遵守即刻平台的[使用条款](https://www.okjike.com/about)
- 避免过于频繁的自动化操作，以免影响账号安全
