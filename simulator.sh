#!/bin/bash
# simulator.sh
# 作用：模拟同事操作，直接推送到你的 GitHub 练习仓库

TASK=$1
CONFIG_FILE=".git_training_config"

# 检查配置
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 未找到配置文件。请先运行 ./init.sh"
    exit 1
fi
REPO_URL=$(cat "$CONFIG_FILE")

# 检查参数
if [ -z "$TASK" ]; then
    echo "❌ 错误：请指定任务 ID。"
    echo "用法: ./simulator.sh [task4 | task5 | task9 | task12]"
    exit 1
fi

# 辅助函数：模拟同事操作
# 辅助函数：模拟同事操作
simulate_coworker() {
    echo "🤖 [Simulator] 同事正在上线..."
    
    if [ ! -d "coworker" ]; then
        echo "❌ 错误：找不到 coworker 目录，请重新运行 init.sh"
        exit 1
    fi

    cd coworker
    
    echo "🔄 同事正在同步你的最新代码..."
    git fetch origin main
    git reset --hard origin/main
    # === 关键修改 END ===
    
    # 执行具体操作（生成新的 commits）
    eval "$1"
    
    # 推送
    echo "📤 同事正在推送代码到 GitHub..."
    git push origin main
    cd ..
    echo "✅ [Simulator] 同事操作已完成。"
}
case $TASK in
    task4)
        echo "⚡ [场景触发] Task 4: 制造 Push 拒绝场景..."
        simulate_coworker '
            cat <<EOF > config.py
# System Configuration
DEBUG = True
VERSION = "1.0.0"
EOF
            git add config.py
            git commit -m "feat: add initial configuration"
        '
        echo "💡 提示：你的远程仓库已有新提交。请在 workspace 尝试 push，然后学习如何 pull。"
        ;;
        
    task5)
        echo "⚡ [场景触发] Task 5: 制造合并冲突..."
        simulate_coworker '
            cat <<EOF > main.py
def hello():
    print("Greetings Universe") # Coworker changed this

if __name__ == "__main__":
    hello()
EOF
            git commit -am "feat: update greeting message"
        '
        echo "💡 提示：请确保你在 workspace 也修改了 main.py 同一行，然后尝试 pull。"
        ;;
        
    task9)
        echo "⚡ [场景触发] Task 9: 生成包含隐患的历史记录..."
        simulate_coworker '
            for i in {1..5}; do
                echo "Log entry $i" >> update.log
                git add update.log
                if [ $i -eq 3 ]; then
                     cat <<EOC >> main.py

# TODO: Refactor this later (Potential Bug)
def hack():
    pass
EOC
                     git commit -am "chore: routine update $i (and minor fix)"
                else
                     git commit -m "chore: routine update $i"
                fi
            done
        '
        echo "💡 提示：运行 git pull，然后用 git blame main.py 抓出是谁写的 TODO。"
        ;;
        
    task12)
        echo "⚡ [场景触发] Task 12: 重置远程仓库并生成 100 个提交..."
        echo "⚠️  警告：这将强制覆盖 GitHub 仓库：$REPO_URL"
        read -p "确认继续吗？(y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        
        # 重新初始化 workspace
        rm -rf workspace coworker
        mkdir workspace
        cd workspace
        git init -b main
        git remote add origin "$REPO_URL"
        
        # 1. 准备初始代码
        cat <<EOF > data_processor.py
def process_data(n):
    return n * 2  # 正常逻辑
EOF
        cat <<EOF > test_runner.py
import sys
from data_processor import process_data

# Test: Input 10, Expect 20
if process_data(10) == 20:
    print("✅ Test Passed")
    sys.exit(0)
else:
    print("❌ Test Failed")
    sys.exit(1)
EOF
        git add .
        git commit -m "init: add processor and test suite"
        
        # 2. 生成历史
        echo "⏳ 正在生成 100 个提交 (这可能需要几秒钟)..."
        for i in {1..100}; do
            echo "Build version 1.0.$i" >> history.log
            if [ $i -eq 66 ]; then
                cat <<EOF > data_processor.py
def process_data(n):
    return n * 0  # <--- BUG
EOF
                git add data_processor.py
                git commit -m "deploy: release version 1.0.$i" > /dev/null
            else
                git add history.log
                git commit -m "deploy: release version 1.0.$i" > /dev/null
            fi
        done
        
        echo "🚀 正在推送到 GitHub..."
        git push -f origin main > /dev/null 2>&1
        cd ..
        
        # 重建 coworker
        git clone "$REPO_URL" coworker > /dev/null 2>&1
        
        echo "✅ Task 12 环境就绪。Bug 在第 66 次提交。"
        ;;
        
    *)
        echo "❌ 未知任务指令。可用: task4, task5, task9, task12"
        ;;
esac