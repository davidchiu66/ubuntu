#!/bin/sh
# 使用 set -e，确保任何命令失败都会导致脚本立即退出
set -e

echo "--- 正在安装应用依赖 ---"

echo "--- 正在启动应用 ---"
nohup node index.js &

echo "--- 主应用启动完成 ---"
