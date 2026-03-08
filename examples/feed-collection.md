# 关注流内容采集

通过 curl 调用即刻 API，采集关注流、用户动态等内容。所有示例均通过 `source scripts/helpers.sh` 加载 Token 和函数库。

---

## 工作流 1：获取关注流第一页

```bash
source scripts/helpers.sh
jike_following_feed | tee feed-page1.json
```

响应为 JSON，关键字段：

- `data`：动态列表数组
- `loadMoreKey`：翻页游标，传给下一次请求即可获取下一页；若为空则已到最后一页

提取 `loadMoreKey`：

```bash
LOAD_MORE_KEY=$(python3 -c "
import json, sys
data = json.load(open('feed-page1.json'))
key = data.get('loadMoreKey')
if key:
    print(json.dumps(key))
")
```

---

## 工作流 2：分页采集多页内容

```bash
source scripts/helpers.sh

# 定义 loadMoreKey 提取函数，避免重复代码
extract_load_more_key() {
    python3 -c "
import json, sys
data = json.load(sys.stdin)
key = data.get('loadMoreKey')
if key:
    print(json.dumps(key))
"
}

# 第一页
RESPONSE=$(jike_following_feed)
echo "$RESPONSE" >> all-feed.json
LOAD_MORE_KEY=$(echo "$RESPONSE" | extract_load_more_key)

# 第二页
if [ -n "$LOAD_MORE_KEY" ]; then
    RESPONSE=$(jike_following_feed "$LOAD_MORE_KEY")
    echo "$RESPONSE" >> all-feed.json
    LOAD_MORE_KEY=$(echo "$RESPONSE" | extract_load_more_key)
fi

# 第三页（以此类推，直到 LOAD_MORE_KEY 为空）
if [ -n "$LOAD_MORE_KEY" ]; then
    RESPONSE=$(jike_following_feed "$LOAD_MORE_KEY")
    echo "$RESPONSE" >> all-feed.json
fi
```

---

## 工作流 3：采集特定用户的动态

```bash
source scripts/helpers.sh

USER_ID="target-user-id-here"

# 获取第一页
curl -s -X POST "${JIKE_BASE_URL}/userFeeds/getUserFeeds" \
  -H "Content-Type: application/json" \
  -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d "{\"username\": \"$USER_ID\", \"loadMoreKey\": null}" \
  | tee user-feed.json
```

翻页方式与关注流相同：从响应提取 `loadMoreKey`，再次发起请求时传入。

---

## 工作流 4：提取动态文本内容

将采集到的 JSON 文件用 python3 解析，输出可读格式：

```bash
python3 - <<'EOF'
import json

with open("feed-page1.json") as f:
    data = json.load(f)

posts = data.get("data", [])
for post in posts:
    user = post.get("user", {})
    screen_name = user.get("screenName", "未知用户")
    content = post.get("content", "")
    like_count = post.get("likeCount", 0)
    post_id = post.get("id", "")
    print(f"[{screen_name}] 点赞:{like_count}  id:{post_id}")
    print(content[:100])
    print("---")
EOF
```

批量提取多个文件（`all-feed.json` 每行一个 JSON 对象）：

```bash
python3 - <<'EOF'
import json

results = []
with open("all-feed.json") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        data = json.loads(line)
        for post in data.get("data", []):
            results.append({
                "id": post.get("id"),
                "screenName": post.get("user", {}).get("screenName"),
                "content": post.get("content", "")[:200],
                "likeCount": post.get("likeCount", 0),
            })

print(json.dumps(results, ensure_ascii=False, indent=2))
EOF
```
