# 社交互动操作

通过 curl 调用即刻 API 完成点赞、评论、关注、话题订阅等操作。所有示例均通过 `source scripts/helpers.sh` 加载 Token 和函数库。

---

## 点赞

```bash
source scripts/helpers.sh
jike_like "<post-id>"
```

`<post-id>` 为动态的唯一 ID，可从关注流响应的 `data[].id` 字段获取。

---

## 评论

```bash
source scripts/helpers.sh
jike_comment "<post-id>" "评论内容"
```

---

## 关注用户

```bash
source scripts/helpers.sh
jike_follow "<user-id>"
```

`<user-id>` 为用户的 `username` 字段（非昵称），可从动态响应的 `user.username` 获取。

---

## 批量点赞

从关注流提取动态 ID 列表，循环点赞，每次操作间隔 1 秒：

```bash
source scripts/helpers.sh

# 获取关注流并提取 ID 列表
POST_IDS=$(jike_following_feed | python3 -c "
import json, sys
data = json.load(sys.stdin)
for post in data.get('data', []):
    print(post['id'])
")

# 逐条点赞
for POST_ID in $POST_IDS; do
    echo "点赞动态: $POST_ID"
    jike_like "$POST_ID"
    sleep 1
done
```

---

## 搜索话题并订阅

```bash
source scripts/helpers.sh

# 搜索话题，获取 topic id
jike_search_topic "Python"
```

从响应中找到目标话题的 `id` 字段，然后订阅：

```bash
TOPIC_ID="topic-id-here"

curl -s -X POST "${JIKE_BASE_URL}/topics/follow" \
  -H "Content-Type: application/json" \
  -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d "{\"topicId\": \"$TOPIC_ID\"}"
```
