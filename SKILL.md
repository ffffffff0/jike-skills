---
name: 即刻（Jike）API 操作
description: |
  通过保存的认证 Token 和 curl/HTTP 请求直接调用即刻 API，
  无需浏览器自动化。适用于：
  - 批量读取关注流、话题、用户动态
  - 点赞、评论、转发等社交互动
  - 发布动态（文字 + 话题）
  - 关注/取关用户、订阅话题
  - 搜索用户、话题、内容
  基于 curl + 即刻逆向工程 API 端点。
allowed-tools:
  - Bash
  - Read
  - Write
---

# 即刻（Jike）API 操作

> **关键规则 — 违反将导致工作流中断：**
>
> 1. 每次操作前必须检查 .env 文件中的 Token 是否已配置，未配置时先引导用户完成认证设置。
> 2. API 端点是逆向工程发现的，可能随时变更；若请求返回 404 或响应格式不符预期，需用 Chrome DevTools Network Tab 重新发现端点。
> 3. 请求频率不能过高：批量操作每次间隔 ≥ 1 秒，避免触发风控。
> 4. 完成操作后必须汇报结果（成功/失败、数据摘要）。

## 概述

Claude Code 读取 .env 中的 Token，用 curl 向即刻 API 发送请求，解析 JSON 响应。不需要浏览器，可完全在终端中运行。

## 何时使用

**适合使用：**
- 批量操作（批量点赞、批量获取动态列表）
- 内容采集（抓取关注流、话题动态）
- 自动化定时任务

**不适合使用：**
- 需要查看页面截图
- 处理验证码
- 操作图片上传

## 前置条件：Token 配置

### 如何从 Chrome 提取即刻 Token

```
步骤 1：打开即刻网页版
  1. 在 Chrome 中打开 https://web.okjike.com
  2. 确保已登录账号

步骤 2：打开 Chrome DevTools
  1. 按 F12 或 右键 → 检查 → 打开 DevTools
  2. 点击顶部 "Application"（应用程序）标签

步骤 3：找到 Token
  1. 左侧导航展开：Storage → Cookies → https://web.okjike.com
  2. 找到名为 "x-jike-access-token" 的条目，复制其 Value
  3. 找到名为 "x-jike-refresh-token" 的条目，复制其 Value

步骤 4：保存配置
  在项目目录下运行：
  bash scripts/setup.sh
  粘贴两个 Token 值，脚本会自动写入 .env 文件
```

### 验证 Token 有效性

```bash
source .env
curl -s -X POST "https://app.jike.ruguoapp.com/1.0/profile/getMyUserInfo" \
  -H "Content-Type: application/json" \
  -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d '{}' | python3 -m json.tool
```

成功响应包含 `"user"` 字段；若返回 401 则 Token 失效，需重新提取。

## API 配置

```bash
BASE_URL="https://app.jike.ruguoapp.com/1.0"

# 每次请求都需要的通用 headers
-H "Content-Type: application/json"
-H "x-jike-access-token: $JIKE_ACCESS_TOKEN"
-H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN"
-H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
```

## 常用操作 API

> **提示：** 项目提供了 `scripts/helpers.sh` 函数库，封装了以下所有 curl 操作。可直接 `source scripts/helpers.sh` 后调用 `jike_me`、`jike_following_feed`、`jike_like` 等函数，无需手动拼写 curl 命令。

### 获取关注流

```bash
source .env
curl -s -X POST "https://app.jike.ruguoapp.com/1.0/userFeeds/followingUpdates" \
  -H "Content-Type: application/json" \
  -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d '{"loadMoreKey": null}' | python3 -m json.tool
```

响应字段说明：`data[]` 是动态列表，每条动态有 `id`、`content`、`likeCount`、`user.screenName`；`loadMoreKey` 用于翻页。

### 点赞动态

```bash
source .env
curl -s -X POST "https://app.jike.ruguoapp.com/1.0/originalPost/like" \
  -H "Content-Type: application/json" \
  -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d '{"id": "<post-id>"}'
```

将 `<post-id>` 替换为从关注流中获取的动态 ID。

### 发表评论

```bash
source .env
curl -s -X POST "https://app.jike.ruguoapp.com/1.0/comment/add" \
  -H "Content-Type: application/json" \
  -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d '{"targetId": "<post-id>", "targetType": "ORIGINAL_POST", "content": "你的评论内容"}'
```

### 发布新动态

```bash
source .env
curl -s -X POST "https://app.jike.ruguoapp.com/1.0/originalPost/save" \
  -H "Content-Type: application/json" \
  -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d '{"content": "动态正文内容"}'
```

可选：添加话题 `"topicId": "<话题id>"`。

### 关注用户

```bash
source .env
curl -s -X POST "https://app.jike.ruguoapp.com/1.0/user/follow" \
  -H "Content-Type: application/json" \
  -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d '{"followId": "<用户id>"}'
```

### 搜索话题

```bash
source .env
curl -s -X POST "https://app.jike.ruguoapp.com/1.0/topic/search" \
  -H "Content-Type: application/json" \
  -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d '{"keywords": "搜索关键词", "pageNo": 1}' | python3 -m json.tool
```

### 获取用户信息

```bash
source .env
curl -s -X POST "https://app.jike.ruguoapp.com/1.0/profile/getUserInfo" \
  -H "Content-Type: application/json" \
  -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d '{"username": "<用户id>"}' | python3 -m json.tool
```

## Token 刷新

当 access-token 过期时（API 返回 401），使用 refresh-token 换取新的 access-token：

```bash
source .env
NEW_TOKEN=$(curl -s -X POST "https://app.jike.ruguoapp.com/1.0/auth/refreshToken" \
  -H "Content-Type: application/json" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d '{}' | python3 -c "import sys,json; print(json.load(sys.stdin).get('accessToken',''))")

# 更新 .env
sed -i '' "s/^JIKE_ACCESS_TOKEN=.*/JIKE_ACCESS_TOKEN=$NEW_TOKEN/" .env
echo "Token 已更新"
```

## 错误处理

- `401 Unauthorized` → access-token 过期，执行 Token 刷新步骤
- `403 Forbidden` → 权限不足（可能账号受限）
- `429 Too Many Requests` → 请求过频，等待后重试
- `404 Not Found` → API 端点已变更，需用 DevTools 重新发现

## 发现新端点的方法

若某操作端点失效，用 Chrome DevTools 发现新端点：

1. 打开 Chrome DevTools → Network 标签
2. 在即刻网页版执行目标操作（点赞、评论等）
3. 在 Network 面板过滤 `app.jike.ruguoapp.com` 或 `m.okjike.com` 请求
4. 找到对应请求，查看 Request URL、Headers 和 Payload

## 最佳实践

1. 每次操作前检查 .env 存在且 token 不为空
2. 批量操作在相邻请求间加 `sleep 1`
3. 解析 JSON 响应用 `python3 -m json.tool` 或 `jq`
4. 保存关注流时用 `>` 重定向到文件便于处理
5. 不要在代码/提交中硬编码 token
6. access-token 通常有效期数小时，refresh-token 有效期更长
7. 如果所有请求都 401，从 Chrome 重新提取两个 token
8. API 端点是非官方的，即刻可能随时修改，出现问题先排查端点是否变化
