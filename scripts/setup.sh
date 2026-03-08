#!/bin/bash
set -e

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${GREEN}"
echo "================================================"
echo "    即刻（Jike）认证配置向导"
echo "================================================"
echo -e "${RESET}"

echo -e "${YELLOW}请按以下步骤从 Chrome 浏览器提取即刻 Token：${RESET}"
echo ""
echo "  步骤 1: 打开 https://web.okjike.com 并确保已登录"
echo "  步骤 2: 按 F12 打开 DevTools → 点击 \"Application\" 标签"
echo "  步骤 3: 左侧展开 Storage → Cookies → https://web.okjike.com"
echo "  步骤 4: 找到 \"x-jike-access-token\"，复制其 Value 列的值"
echo "  步骤 5: 找到 \"x-jike-refresh-token\"，复制其 Value 列的值"
echo ""

# Read access token
echo -e "${BLUE}请粘贴 x-jike-access-token 的值：${RESET}"
read -r access_token

# Read refresh token
echo -e "${BLUE}请粘贴 x-jike-refresh-token 的值：${RESET}"
read -r refresh_token

# Validate inputs
if [ -z "$access_token" ] || [ -z "$refresh_token" ]; then
    echo -e "${RED}错误：Token 不能为空，请重新运行脚本。${RESET}"
    exit 1
fi

# Write .env file
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cat > "${SCRIPT_DIR}/.env" <<EOF
JIKE_ACCESS_TOKEN=${access_token}
JIKE_REFRESH_TOKEN=${refresh_token}
JIKE_BASE_URL=https://app.jike.ruguoapp.com/1.0
EOF

echo ""
echo -e "${YELLOW}正在验证 Token 有效性...${RESET}"

# Validate token by calling API
response=$(curl -s -X POST "https://app.jike.ruguoapp.com/1.0/profile/getMyUserInfo" \
    -H "Content-Type: application/json" \
    -H "x-jike-access-token: ${access_token}" \
    -H "x-jike-refresh-token: ${refresh_token}" \
    -d '{}' || true)

screen_name=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('data', {}).get('user', {}).get('screenName', ''))" 2>/dev/null || true)
if [ -n "$screen_name" ]; then
    echo ""
    echo -e "${GREEN}================================================${RESET}"
    echo -e "${GREEN}  Token 验证成功！${RESET}"
    echo -e "${GREEN}  欢迎，${screen_name}！${RESET}"
    echo -e "${GREEN}================================================${RESET}"
    echo ""
    echo -e "  Token 已保存到 ${BLUE}.env${RESET} 文件"
    echo -e "  现在可以开始使用即刻技能了！"
    echo ""
    echo -e "${YELLOW}提示：.env 已在 .gitignore 中保护，不会被提交到代码仓库。${RESET}"
else
    echo ""
    echo -e "${RED}================================================${RESET}"
    echo -e "${RED}  Token 验证失败！${RESET}"
    echo -e "${RED}================================================${RESET}"
    echo ""
    echo -e "  响应内容：${response}"
    echo ""
    echo -e "${YELLOW}建议：请确认已登录即刻，并重新从 Chrome DevTools 提取最新的 Token 后再次运行脚本。${RESET}"
    exit 1
fi
