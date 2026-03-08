# 即刻 API 端点参考

BASE_URL: `https://app.jike.ruguoapp.com/1.0`

所有请求为 POST，需携带以下 headers：
```
Content-Type: application/json
x-jike-access-token: $JIKE_ACCESS_TOKEN
x-jike-refresh-token: $JIKE_REFRESH_TOKEN
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36
```

## 端点速查表

| 操作 | 端点 | 请求体 |
|------|------|--------|
| 我的信息 | `/profile/getMyUserInfo` | `{}` |
| 关注流 | `/userFeeds/followingUpdates` | `{"loadMoreKey": null}` |
| 推荐流 | `/userFeeds/recommendedUpdates` | `{"loadMoreKey": null}` |
| 点赞 | `/originalPost/like` | `{"id": "<post-id>"}` |
| 取消点赞 | `/originalPost/unlike` | `{"id": "<post-id>"}` |
| 评论 | `/comment/add` | `{"targetId": "<id>", "targetType": "ORIGINAL_POST", "content": "..."}` |
| 发动态 | `/originalPost/save` | `{"content": "...", "topicId": "<可选>"}` |
| 删动态 | `/originalPost/remove` | `{"id": "<post-id>"}` |
| 关注用户 | `/user/follow` | `{"followId": "<user-id>"}` |
| 取关用户 | `/user/unfollow` | `{"followId": "<user-id>"}` |
| 用户信息 | `/profile/getUserInfo` | `{"username": "<user-id>"}` |
| 搜索话题 | `/topic/search` | `{"keywords": "...", "pageNo": 1}` |
| 刷新 Token | `/auth/refreshToken` | `{}` (只需 refresh-token header) |

## 关注流响应结构

```json
{
  "data": [
    {
      "id": "post-id",
      "content": "动态正文",
      "likeCount": 42,
      "commentCount": 5,
      "user": { "screenName": "用户名", "id": "user-id" },
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "loadMoreKey": { ... }  // 翻页 key，null 表示没有更多
}
```

## 错误码

| 状态码 | 原因 | 处理方式 |
|--------|------|----------|
| 401 | access-token 过期 | 调用 `jike_refresh_token` |
| 403 | 权限不足 | 检查账号状态 |
| 429 | 请求过频 | sleep 后重试 |
| 404 | 端点已变更 | 用 DevTools 重新发现 |

## 发现新端点

若端点返回 404，用 Chrome DevTools 找新端点：
1. DevTools → Network 标签
2. 在即刻网页执行目标操作
3. 过滤 `app.jike.ruguoapp.com` 请求
4. 查看 Request URL + Payload
