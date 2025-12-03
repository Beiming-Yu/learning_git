#!/bin/bash
# init.sh
# 作用：初始化 Git 训练环境，连接真实的 GitHub 仓库

set -e

# 配置文件，用于保存远程仓库地址，供 simulator.sh 使用
CONFIG_FILE=".git_training_config"

echo "🏗️  正在初始化 Git 训练环境 (GitHub Mode)..."

# 1. 获取远程仓库地址
if [ -f "$CONFIG_FILE" ]; then
    SAVED_URL=$(cat "$CONFIG_FILE")
    echo "检测到上次使用的仓库: $SAVED_URL"
    read -p "是否继续使用该仓库？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        REPO_URL="$SAVED_URL"
    fi
fi

if [ -z "$REPO_URL" ]; then
    echo "Please create a NEW (or expendable) repository on GitHub."
    echo "⚠️  警告：该仓库的所有内容将被此脚本强制覆盖！"
    echo "请输入练习用的 GitHub 仓库地址 (例如: git@github.com:username/demo.git):"
    read -r REPO_URL
    echo "$REPO_URL" > "$CONFIG_FILE"
fi

# 2. 清理旧环境
echo "🧹 清理旧目录..."
rm -rf workspace coworker

# 3. 初始化你的工作区 (workspace)
echo "🔧 初始化 Workspace..."
mkdir workspace
cd workspace
git init -b main
git remote add origin "$REPO_URL"

# 配置虚拟身份 (仅限本地仓库配置，不影响全局)
git config user.name "Someone"
git config user.email "someone@example.com"

# 创建初始文件
echo "# Python Project Simulation" > README.md
cat <<EOF > main.py
def hello():
    print("System Online.")

if __name__ == "__main__":
    hello()
EOF

# 初始提交并强制推送到远程
git add .
git commit -m "init: project setup"

echo "🚀 正在强制推送到 GitHub (这将覆盖远程仓库)..."
git push -f origin main
cd ..

# 4. 初始化同事工作区 (coworker)
echo "👥 正在克隆 Coworker 环境..."
git clone "$REPO_URL" coworker
cd coworker
git config user.name "Coworker"
git config user.email "coworker@training.com"
cd ..

# 赋予权限
chmod +x init.sh
[ -f simulator.sh ] && chmod +x simulator.sh

echo ""
echo "✅ 环境初始化完成！"
echo "🔗 远程仓库: $REPO_URL"
echo "📂 请进入 'workspace' 目录开始练习。"