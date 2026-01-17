#!/bin/bash

# Git Push Tool - 自动提交并推送所有修改到远程仓库
# 用法: ./git_push.sh [commit message]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 获取脚本所在目录的上级目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo -e "${GREEN}=== Git Push Tool ===${NC}"
echo -e "项目目录: $PROJECT_ROOT"
echo ""

# 检查是否是git仓库
if [ ! -d ".git" ]; then
    echo -e "${RED}错误: 当前目录不是git仓库${NC}"
    exit 1
fi

# 显示当前状态
echo -e "${YELLOW}当前git状态:${NC}"
git status --short

# 检查是否有修改
if [ -z "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}没有需要提交的修改${NC}"
    exit 0
fi

# 获取commit message
if [ -n "$1" ]; then
    COMMIT_MSG="$1"
else
    # 生成默认的commit message，包含日期时间
    COMMIT_MSG="Update $(date '+%Y-%m-%d %H:%M:%S')"
fi

echo ""
echo -e "${GREEN}添加所有修改...${NC}"
git add -A

echo -e "${GREEN}提交修改...${NC}"
echo -e "Commit message: ${YELLOW}$COMMIT_MSG${NC}"
git commit -m "$COMMIT_MSG"

echo ""
echo -e "${GREEN}推送到远程仓库...${NC}"
git push

echo ""
echo -e "${GREEN}=== 完成! ===${NC}"
