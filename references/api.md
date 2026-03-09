# 即刻 API 端点参考

BASE_URL: `https://api.ruguoapp.com`（从 web.okjike.com JS bundle 逆向获得）

认证 headers（每次请求必须携带）：
```
Content-Type: application/json
x-jike-access-token: $JIKE_ACCESS_TOKEN
x-jike-refresh-token: $JIKE_REFRESH_TOKEN
```

## 端点速查表

| 操作 | 方法 | 端点 | 请求体 |
|------|------|------|--------|
| 刷新 Token | POST | `/app_auth_tokens.refresh` | `{}` (只需 refresh-token) |
| 我的信息 | GET | `/1.0/users/profile` | — |
| 关注流 | POST | `/1.0/personalUpdate/followingUpdates` | `{"loadMoreKey": null}` |
| 推荐流 | POST | `/1.0/recommendFeed/list` | `{"loadMoreKey": null}` |
| 点赞动态 | POST | `/1.0/originalPosts/like` | `{"id": "<post-id>"}` |
| 取消点赞 | POST | `/1.0/originalPosts/unlike` | `{"id": "<post-id>"}` |
| 发布动态 | POST | `/1.0/originalPosts/create` | `{"content": "...", "topicId": "<可选>"}` |
| 删除动态 | POST | `/1.0/originalPosts/remove` | `{"id": "<post-id>"}` |
| 评论 | POST | `/1.0/comments/add` | `{"targetId": "<id>", "targetType": "ORIGINAL_POST", "content": "..."}` |
| 删除评论 | POST | `/1.0/comments/remove` | `{"id": "<comment-id>"}` |
| 转发 | POST | `/1.0/reposts/add` | `{"targetId": "<id>", "targetType": "ORIGINAL_POST", "content": "..."}` |
| 关注用户 | POST | `/1.0/userRelation/follow` | `{"targetUserId": "<user-id>"}` |
| 取关用户 | POST | `/1.0/userRelation/unfollow` | `{"targetUserId": "<user-id>"}` |
| 关注者列表 | POST | `/1.0/userRelation/getFollowerList` | `{"userId": "<user-id>"}` |
| 关注列表 | POST | `/1.0/userRelation/getFollowingList` | `{"userId": "<user-id>"}` |
| 话题详情 | POST | `/1.0/topics/getDetail` | `{"id": "<topic-id>"}` |
| 已订阅话题 | GET | `/1.0/topics/listSubscribed` | — |
| 订阅话题 | POST | `/1.0/users/topics/changeSubscriptionStatus` | `{"topicId": "<id>", "status": "SUBSCRIBED"}` |
| 搜索 | POST | `/1.0/search/integrate` | `{"keywords": "..."}` |
| 通知列表 | POST | `/1.0/notifications/list` | `{"loadMoreKey": null}` |
| 未读通知数 | GET | `/1.0/notifications/unread` | — |

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
  "loadMoreKey": { ... }
}
```

翻页：把上次响应中的 `loadMoreKey` 原样传给下次请求的 `loadMoreKey` 字段。

## 错误码

| 状态/响应 | 原因 | 处理方式 |
|-----------|------|----------|
| `{"success":false}` | access-token 过期 | 自动刷新重试（无需手动处理）；若仍失败运行 `bash scripts/setup.sh` |
| HTTP 401 | 未认证 | 检查 header 是否正确 |
| HTTP 404 | 端点变更 | 重新从 JS bundle 发现 |

## 发现新端点

从 Jike web app JS bundle 提取所有端点：
```bash
curl -s "https://web.okjike.com/" | grep -o 'src="/assets/[^"]*\.js"' | head -1
# 然后：
curl -s "https://web.okjike.com/assets/<bundle>.js" | grep -oE '"/[0-9]+\.[0-9]+/[a-zA-Z/]+"' | sort -u
```

或用 Chrome DevTools → Network → 过滤 `api.ruguoapp.com` 请求查看实时调用。
