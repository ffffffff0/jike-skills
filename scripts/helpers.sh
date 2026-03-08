#!/bin/bash
# 即刻（Jike）API 操作函数库
# 使用方法：source scripts/helpers.sh
# 前提：当前目录存在 .env 文件

# === 初始化 ===

# 检查并加载 .env
if [ ! -f ".env" ]; then
  echo "错误：未找到 .env 文件。请先运行 bash scripts/setup.sh 配置 Token。"
  return 1 2>/dev/null || exit 1
fi
source .env

# 验证必要变量
if [ -z "$JIKE_ACCESS_TOKEN" ] || [ -z "$JIKE_REFRESH_TOKEN" ]; then
  echo "错误：.env 中缺少 JIKE_ACCESS_TOKEN 或 JIKE_REFRESH_TOKEN"
  return 1 2>/dev/null || exit 1
fi

JIKE_BASE_URL="${JIKE_BASE_URL:-https://app.jike.ruguoapp.com/1.0}"

# === 内部辅助函数 ===

# jike_request <endpoint> [json_body]
# 发送通用 POST 请求，返回 JSON 响应
jike_request() {
  local endpoint="$1"
  local body="${2:-{}}"
  curl -s -X POST "${JIKE_BASE_URL}${endpoint}" \
    -H "Content-Type: application/json" \
    -H "x-jike-access-token: $JIKE_ACCESS_TOKEN" \
    -H "x-jike-refresh-token: $JIKE_REFRESH_TOKEN" \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    -d "$body"
}

# _jike_print <response>
# 检查响应非空并格式化输出 JSON；失败时打印原始响应
_jike_print() {
  local response="$1"
  if [ -z "$response" ]; then
    echo "错误：请求失败，请检查网络连接或 Token 是否有效。"
    return 1
  fi
  echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
}

# _jike_feed <endpoint> [loadMoreKey]
# 通用翻页 feed 请求（关注流 / 推荐流共用）
_jike_feed() {
  local endpoint="$1"
  local load_more_key="$2"
  local body='{"loadMoreKey": null}'
  [ -n "$load_more_key" ] && body="{\"loadMoreKey\": ${load_more_key}}"
  _jike_print "$(jike_request "$endpoint" "$body")"
}

# === 公开函数 ===

# jike_me
# 获取当前登录用户信息
jike_me() {
  _jike_print "$(jike_request "/profile/getMyUserInfo")"
}

# jike_following_feed [loadMoreKey]
# 获取关注流动态列表
# 参数：loadMoreKey（可选，用于翻页，从上次响应中获取）
jike_following_feed() {
  _jike_feed "/userFeeds/followingUpdates" "$1"
}

# jike_recommended_feed [loadMoreKey]
# 获取推荐流动态列表
# 参数：loadMoreKey（可选，用于翻页，从上次响应中获取）
jike_recommended_feed() {
  _jike_feed "/userFeeds/recommendedUpdates" "$1"
}

# jike_like <post_id>
# 点赞指定动态
# 参数：post_id - 动态 ID（从 feed 响应中的 id 字段获取）
jike_like() {
  local post_id="$1"
  if [ -z "$post_id" ]; then
    echo "用法：jike_like <post_id>"
    echo "参数：post_id - 动态 ID（从 feed 响应中的 id 字段获取）"
    return 1
  fi
  _jike_print "$(jike_request "/originalPost/like" "{\"id\": \"${post_id}\"}")"
}

# jike_unlike <post_id>
# 取消点赞
# 参数：post_id - 动态 ID
jike_unlike() {
  local post_id="$1"
  if [ -z "$post_id" ]; then
    echo "用法：jike_unlike <post_id>"
    echo "参数：post_id - 动态 ID"
    return 1
  fi
  _jike_print "$(jike_request "/originalPost/unlike" "{\"id\": \"${post_id}\"}")"
}

# jike_comment <post_id> <content>
# 给动态发表评论
# 参数：post_id - 动态 ID；content - 评论文字内容
jike_comment() {
  local post_id="$1"
  local content="$2"
  if [ -z "$post_id" ] || [ -z "$content" ]; then
    echo "用法：jike_comment <post_id> <content>"
    echo "参数：post_id - 动态 ID；content - 评论文字内容"
    return 1
  fi
  local body
  body=$(python3 -c "import json,sys; print(json.dumps({'targetId': sys.argv[1], 'targetType': 'ORIGINAL_POST', 'content': sys.argv[2]}))" "$post_id" "$content")
  _jike_print "$(jike_request "/comment/add" "$body")"
}

# jike_post <content> [topic_id]
# 发布新动态
# 参数：content - 动态正文；topic_id（可选）- 话题 ID
jike_post() {
  local content="$1"
  local topic_id="$2"
  if [ -z "$content" ]; then
    echo "用法：jike_post <content> [topic_id]"
    echo "参数：content - 动态正文；topic_id（可选）- 话题 ID"
    return 1
  fi
  local body
  body=$(python3 -c "
import json, sys
d = {'content': sys.argv[1], 'pictureKeys': [], 'syncToPersonalUpdates': True}
if len(sys.argv) > 2 and sys.argv[2]:
    d['topicId'] = sys.argv[2]
print(json.dumps(d))
" "$content" "${topic_id:-}")
  _jike_print "$(jike_request "/originalPost/save" "$body")"
}

# jike_follow <user_id>
# 关注用户
# 参数：user_id - 用户 ID
jike_follow() {
  local user_id="$1"
  if [ -z "$user_id" ]; then
    echo "用法：jike_follow <user_id>"
    echo "参数：user_id - 用户 ID"
    return 1
  fi
  _jike_print "$(jike_request "/user/follow" "{\"followId\": \"${user_id}\"}")"
}

# jike_unfollow <user_id>
# 取关用户
# 参数：user_id - 用户 ID
jike_unfollow() {
  local user_id="$1"
  if [ -z "$user_id" ]; then
    echo "用法：jike_unfollow <user_id>"
    echo "参数：user_id - 用户 ID"
    return 1
  fi
  _jike_print "$(jike_request "/user/unfollow" "{\"followId\": \"${user_id}\"}")"
}

# jike_user <user_id>
# 获取指定用户信息
# 参数：user_id - 用户 ID
jike_user() {
  local user_id="$1"
  if [ -z "$user_id" ]; then
    echo "用法：jike_user <user_id>"
    echo "参数：user_id - 用户 ID"
    return 1
  fi
  _jike_print "$(jike_request "/profile/getUserInfo" "{\"username\": \"${user_id}\"}")"
}

# jike_search_topic <keywords> [page]
# 搜索话题
# 参数：keywords - 搜索关键词；page（可选，默认 1）
jike_search_topic() {
  local keywords="$1"
  local page="${2:-1}"
  if [ -z "$keywords" ]; then
    echo "用法：jike_search_topic <keywords> [page]"
    echo "参数：keywords - 搜索关键词；page（可选，默认 1）"
    return 1
  fi
  local body
  body=$(printf '{"keywords": "%s", "pageNo": %s}' "$keywords" "$page")
  _jike_print "$(jike_request "/topic/search" "$body")"
}

# jike_delete_post <post_id>
# 删除自己发布的动态
# 参数：post_id - 动态 ID
jike_delete_post() {
  local post_id="$1"
  if [ -z "$post_id" ]; then
    echo "用法：jike_delete_post <post_id>"
    return 1
  fi
  _jike_print "$(jike_request "/originalPost/remove" "{\"id\": \"${post_id}\"}")"
}

# jike_topic_follow <topic_id>
# 订阅话题
# 参数：topic_id - 话题 ID（从 jike_search_topic 响应中获取）
jike_topic_follow() {
  local topic_id="$1"
  if [ -z "$topic_id" ]; then
    echo "用法：jike_topic_follow <topic_id>"
    return 1
  fi
  _jike_print "$(jike_request "/topics/follow" "{\"topicId\": \"${topic_id}\"}")"
}

# jike_refresh_token
# 刷新 access-token（当出现 401 错误时使用）
# 自动更新 .env 文件中的 JIKE_ACCESS_TOKEN
jike_refresh_token() {
  local response
  response=$(jike_request "/auth/refreshToken")
  if [ -z "$response" ]; then
    echo "错误：请求失败，请检查网络连接或 Refresh Token 是否有效。"
    return 1
  fi
  local new_token
  new_token=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('x-jike-access-token', ''))" 2>/dev/null)
  if [ -z "$new_token" ]; then
    echo "错误：无法从响应中解析新的 access-token，原始响应："
    _jike_print "$response"
    return 1
  fi
  # 更新内存中的变量
  JIKE_ACCESS_TOKEN="$new_token"
  # 更新 .env 文件
  if grep -q "JIKE_ACCESS_TOKEN" .env; then
    sed -i.bak "s|JIKE_ACCESS_TOKEN=.*|JIKE_ACCESS_TOKEN=${new_token}|" .env && rm -f .env.bak
  else
    echo "JIKE_ACCESS_TOKEN=${new_token}" >> .env
  fi
  echo "access-token 已刷新并更新至 .env 文件。"
}

echo "即刻 API 函数库已加载。可用函数：jike_me, jike_following_feed, jike_recommended_feed, jike_like, jike_unlike, jike_comment, jike_post, jike_delete_post, jike_follow, jike_unfollow, jike_user, jike_search_topic, jike_topic_follow, jike_refresh_token"
