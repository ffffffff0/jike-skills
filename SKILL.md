---
name: 即刻（Jike）API 操作
description: |
  通过保存的认证 Token 和 curl/HTTP 请求直接调用即刻 API，无需浏览器自动化。
  当用户想要操作即刻（Jike / web.okjike.com）社交平台时使用，包括：
  - 读取关注流、话题、用户动态
  - 点赞、评论、转发等社交互动
  - 发布动态（文字 + 话题）
  - 关注/取关用户、订阅话题
  - 搜索用户、话题、内容
  - 批量操作和定时自动化任务
  不适合：处理验证码、图片上传、需要截图的操作。
  基于 curl + 逆向工程 API 端点（scripts/helpers.sh 封装了所有操作）。
---

# 即刻（Jike）API 操作

> **关键规则 — 违反将导致工作流中断：**
>
> 1. 每次操作前必须检查 .env 文件中的 Token 是否已配置，未配置时先引导用户完成认证设置。
> 2. API 端点是逆向工程发现的，可能随时变更；若请求返回 404 或响应格式不符预期，需用 Chrome DevTools Network Tab 重新发现端点。
> 3. 请求频率不能过高：批量操作每次间隔 ≥ 1 秒，避免触发风控。
> 4. 完成操作后必须汇报结果（成功/失败、数据摘要）。

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
source scripts/helpers.sh
jike_me
```

成功响应包含 `"screenName"` 字段；若返回错误则 Token 失效，需重新运行 `bash scripts/setup.sh`。


## 执行操作

优先使用 `scripts/helpers.sh` 封装好的函数：

```bash
source scripts/helpers.sh

jike_me                           # 验证登录 + 查看个人信息
jike_following_feed               # 关注流（首页）
jike_like "<post-id>"             # 点赞
jike_comment "<post-id>" "内容"   # 评论
jike_post "动态内容"              # 发布动态
jike_post "内容" "<topic-id>"     # 发布带话题的动态
jike_follow "<user-id>"           # 关注用户
jike_search_topic "关键词"        # 搜索话题
jike_refresh_token                # 手动刷新 token（通常无需调用，失败自动触发）
```

**API 端点和请求格式**：见 [references/api.md](references/api.md)

**多步工作流**（分页采集、批量点赞、定时发布等）：见 [references/workflows.md](references/workflows.md)

## 最佳实践

- **Token 自动刷新**：access-token 过期时，`jike_request`/`jike_get` 会自动调用 `jike_refresh_token` 并重试一次，无需手动干预；若仍失败，重新运行 `bash scripts/setup.sh`
- 批量操作在请求间加 `sleep 1`，避免触发风控
- 解析 JSON 用 `python3 -m json.tool` 或 `jq`
- API 端点是非官方的，遇到 404 参考 [references/api.md](references/api.md) 中的"发现新端点"步骤
