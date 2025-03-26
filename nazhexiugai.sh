#!/bin/bash

# 检查 nezha-agent 服务状态，如果异常或不存在则停止脚本
echo "检查 nezha-agent 服务状态..."
systemctl status nezha-agent.service
if [ $? -ne 0 ]; then
    echo "错误: nezha-agent 服务不存在或运行异常，脚本终止。"
    exit 1
fi

# 停止 nezha-agent 服务
echo "停止 nezha-agent 服务..."
systemctl stop nezha-agent.service

# 等待 3 秒
echo "等待 3 秒..."
sleep 3

# 配置文件路径
CONFIG_FILE="/opt/nezha/agent/config.yml"

echo "检查配置文件是否存在..."
# 检查文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 配置文件 $CONFIG_FILE 不存在！"
    exit 1
fi

echo "检查 disable_auto_update: true 是否存在..."
# 检查 disable_auto_update: true 是否存在
if ! grep -q "disable_auto_update: true" "$CONFIG_FILE"; then
    echo "错误: 配置文件中未找到 disable_auto_update: true，脚本终止。"
    exit 1
fi

echo "检查 disable_force_update: true 是否存在..."
# 检查 disable_force_update: true 是否存在
if ! grep -q "disable_force_update: true" "$CONFIG_FILE"; then
    echo "错误: 配置文件中未找到 disable_force_update: true，脚本终止。"
    exit 1
fi

echo "修改 disable_auto_update: true -> disable_auto_update: false..."
# 修改配置文件中的 disable_auto_update: true 为 disable_auto_update: false
sed -i 's/disable_auto_update: true/disable_auto_update: false/g' "$CONFIG_FILE"

echo "修改 disable_force_update: true -> disable_force_update: false..."
# 修改配置文件中的 disable_force_update: true 为 disable_force_update: false
sed -i 's/disable_force_update: true/disable_force_update: false/g' "$CONFIG_FILE"

echo "修改完成: disable_auto_update 和 disable_force_update 现已设置为 false"

echo "下载最新的 nezha-agent..."
# 下载最新的 nezha-agent
wget -O /opt/nezha/agent/nezha-agent https://raw.githubusercontent.com/ly892009/nezha/refs/heads/main/download/nezha-agent

# 检查下载是否成功
if [ $? -ne 0 ]; then
    echo "错误: nezha-agent 下载失败，脚本终止。"
    exit 1
fi

echo "启动 nezha-agent 服务..."
# 启动 nezha-agent 服务
systemctl start nezha-agent.service

# 检查 nezha-agent 服务状态
echo "检查 nezha-agent 服务状态..."
systemctl status nezha-agent.service
