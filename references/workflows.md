# 即刻操作工作流

## 分页采集关注流

```bash
source scripts/helpers.sh

extract_load_more_key() {
    python3 -c "
import json, sys
data = json.load(sys.stdin)
key = data.get('loadMoreKey')
if key:
    print(json.dumps(key))
"
}

> all-feed.json  # 清空文件

LOAD_MORE_KEY=""
for PAGE in 1 2 3; do
    RESPONSE=$(jike_following_feed "$LOAD_MORE_KEY")
    echo "$RESPONSE" >> all-feed.json
    LOAD_MORE_KEY=$(echo "$RESPONSE" | extract_load_more_key)
    [ -z "$LOAD_MORE_KEY" ] && break
    sleep 1
done
```

## 采集特定用户的动态

```bash
source scripts/helpers.sh

curl -s -X POST "${JIKE_BASE_URL}/userFeeds/getUserFeeds" \
  -H "Content-Type: application/json" \
  -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d '{"username": "<user-id>", "loadMoreKey": null}' | tee user-feed.json
```

翻页方式与关注流相同。

## 解析 JSON 输出可读格式

```bash
python3 - <<'EOF'
import json

results = []
with open("all-feed.json") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        for post in json.loads(line).get("data", []):
            results.append({
                "id": post.get("id"),
                "user": post.get("user", {}).get("screenName"),
                "content": post.get("content", "")[:200],
                "likeCount": post.get("likeCount", 0),
            })

print(json.dumps(results, ensure_ascii=False, indent=2))
EOF
```

## 批量点赞关注流

```bash
source scripts/helpers.sh

POST_IDS=$(jike_following_feed | python3 -c "
import json, sys
for post in json.load(sys.stdin).get('data', []):
    print(post['id'])
")

for POST_ID in $POST_IDS; do
    echo "点赞: $POST_ID"
    jike_like "$POST_ID"
    sleep 1
done
```

## 定时发布（crontab）

将发布操作写成独立脚本 `scripts/morning-post.sh`：

```bash
#!/bin/bash
source "$(dirname "$0")/helpers.sh"
jike_post "早安！新的一天开始了。"
```

添加 crontab（每天早上 9 点）：

```
0 9 * * * bash /path/to/jike-skills/scripts/morning-post.sh
```
