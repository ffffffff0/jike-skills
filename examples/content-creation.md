# 内容创作

通过 curl 调用即刻 API 发布动态、带话题发布、定时发布及删除动态。所有示例均通过 `source scripts/helpers.sh` 加载 Token 和函数库。

---

## 发布纯文字动态

```bash
source scripts/helpers.sh
jike_post "动态内容"
```

---

## 发布带话题的动态

先搜索话题获取 `topicId`，再发布：

```bash
source scripts/helpers.sh

# 搜索话题，找到目标话题的 id
jike_search_topic "读书"
```

从搜索结果中复制目标话题的 `id`，然后发布（`jike_post` 的第二个参数即为 `topicId`）：

```bash
jike_post "最近在读《人月神话》，关于软件项目管理的思考依然不过时。" "topic-id-here"
```

---

## 定时发布（crontab）

将发布操作写成独立脚本，通过 crontab 定时触发：

```bash
# 编辑 crontab
crontab -e
```

添加以下行（每天早上 9 点发布动态）：

```
0 9 * * * cd /path/to/jike-skills && source scripts/helpers.sh && jike_post "早安！新的一天开始了。"
```

也可以单独写一个脚本文件 `scripts/morning-post.sh`：

```bash
#!/bin/bash
source "$(dirname "$0")/helpers.sh"
jike_post "早安！新的一天开始了。"
```

然后在 crontab 中调用：

```
0 9 * * * bash /path/to/jike-skills/scripts/morning-post.sh
```

---

## 删除动态

```bash
source scripts/helpers.sh

POST_ID="post-id-to-delete"

curl -s -X POST "${JIKE_BASE_URL}/originalPost/remove" \
  -H "Content-Type: application/json" \
  -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
  -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
  -d "{\"id\": \"$POST_ID\"}"
```
