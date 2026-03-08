# 即刻（Jike）API 操作技能

## 简介

通过 Token + curl 调用即刻 API，无需浏览器，适合自动化和批量操作。提取登录后的 Cookie Token，保存在本地 `.env` 文件中，所有操作通过纯 HTTP 请求完成。

## 特性

- 不依赖浏览器或 Midscene 等自动化框架
- 可在命令行、脚本、crontab 中直接运行
- 支持批量操作（翻页采集、批量点赞等）
- Token 存储在 `.env` 文件中，`.gitignore` 防止意外提交

## 快速开始

**第 1 步：克隆项目**

```bash
git clone <repo-url> jike-skills
cd jike-skills
```

**第 2 步：配置 Token**

运行引导脚本，按提示从 Chrome DevTools 中提取 `x-jike-access-token` 并保存：

```bash
bash scripts/setup.sh
```

手动提取方法：打开 Chrome，登录 [web.okjike.com](https://web.okjike.com)，按 F12 打开 DevTools，切到 Network 标签，刷新页面，找到任意 API 请求，在 Request Headers 中复制 `x-jike-access-token` 的值。

**第 3 步：加载函数库**

```bash
source scripts/helpers.sh
```

**第 4 步：测试连接**

```bash
jike_me
```

返回当前登录用户信息则说明 Token 有效。

**第 5 步：开始操作**

```bash
jike_following_feed          # 查看关注流
jike_like "post-id-here"     # 点赞
jike_post "今天天气不错"     # 发布动态
```

## 主要操作一览

```bash
source scripts/helpers.sh

# 查看个人信息
jike_me

# 关注流
jike_following_feed

# 翻页（传入上一页返回的 loadMoreKey）
jike_following_feed "$LOAD_MORE_KEY"

# 点赞动态
jike_like "<post-id>"

# 评论动态
jike_comment "<post-id>" "评论内容"

# 关注用户
jike_follow "<user-id>"

# 发布动态
jike_post "动态内容"

# 搜索话题
jike_search_topic "Python"

# 获取特定用户动态
jike_user "<user-id>"
```

## 文件结构

```
jike-skills/
├── .env.example     # Token 配置模板
├── .gitignore       # 保护 .env 不被提交
├── README.md
├── SKILL.md         # Claude Code 技能主文件
└── scripts/
    ├── setup.sh     # Token 配置引导脚本
    └── helpers.sh   # curl 操作函数库
```

## 示例文档

- [关注流内容采集](examples/feed-collection.md)
- [社交互动操作](examples/social-interactions.md)
- [内容创作](examples/content-creation.md)

## 注意事项

- 即刻 API 端点来自逆向工程，可能随版本更新而变化
- 请勿频繁调用 API，建议操作之间加入适当延迟（`sleep 1`）
- 仅供个人使用和学习目的，请遵守即刻平台[使用条款](https://www.okjike.com/about)
