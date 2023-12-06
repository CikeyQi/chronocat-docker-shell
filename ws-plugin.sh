#!/bin/bash

# 添加颜色变量
RED="\e[31m"           # 红色
GREEN="\e[32m"         # 绿色
YELLOW="\e[33m"        # 黄色
RESET="\e[0m"          # 重置颜色

# 添加函数以显示不同颜色的消息
print_message() {
    local message="$1"
    local color="$2"
    echo -e "${color}${message}${RESET}"
}

print_message "欢迎使用 ChronoCat 一键安装脚本" "$GREEN"
print_message "本脚本将安装并配置ws-plugin，请先部署NTQQ后再使用" "$GREEN"
print_message "一键部署NTQQ脚本：https://github.com/CikeyQi/chronocat-docker-shell" "$GREEN"
print_message "脚本遇到问题请加群寻找解决方法：551081559" "$GREEN"

print_message "正在检查环境..." "$GREEN"

# 检查是否安装了Git
if ! command -v git &> /dev/null; then
    print_message "请先安装Git" "$RED"
    exit 1
fi

# 检查是否安装了pnpm
if ! command -v pnpm &> /dev/null; then
    print_message "请先安装pnpm" "$RED"
    exit 1
fi

# 检查当前目录是否存在plugins文件夹
if [ ! -d "plugins" ]; then
    print_message "请在Yunzai根目录下运行此脚本" "$RED"
    exit 1
fi

# 检查当前目录是否存在plugins/ws-plugin文件夹
if [ -d "plugins/ws-plugin" ]; then
    print_message "检测到您已经安装了ws-plugin，正在删除..." "$GREEN"
    rm -rf ./plugins/ws-plugin/
fi

print_message "正在克隆ws-plugin仓库..." "$GREEN"

# 克隆ws-plugin仓库到plugins/ws-plugin目录
git clone --depth=1 -b red https://gitee.com/xiaoye12123/ws-plugin.git ./plugins/ws-plugin/

print_message "正在安装依赖..." "$GREEN"

# 安装依赖
pnpm install --filter=ws-plugin

# 用户选择TRSS-Yunzai或Miao-Yunzai
echo "请选择您使用的Yunzai-Bot版本："
echo "1. TRSS-Yunzai"
echo "2. Miao-Yunzai"
read -p "请输入数字[1/2]：" version

# 检查用户输入是否合法
if [[ -z "$version" && "$version" != "1" && "$version" != "2" ]]; then
  echo "请输入数字[1/2]"
  exit 1
fi

# 如果是Miao-Yunzai，则下载apps.js放在根目录
if [ "$version" == "2" ]; then
    print_message "正在下载配置文件..." "$GREEN"
    wget https://gitee.com/Zyy955/Yunzai-Bot-plugin/raw/main/apps.js -O apps.js
fi

# 如果没有则新建ws-plugin/config/config/目录
if [ ! -d "./plugins/ws-plugin/config/config/" ]; then
    mkdir ./plugins/ws-plugin/config/config/
fi

# 检查是否存在ws-plugin/config/config/ws-config.yaml，如果存在则删除
if [ -f "./plugins/ws-plugin/config/config/ws-config.yaml" ]; then
    rm ./plugins/ws-plugin/config/config/ws-config.yaml
fi

print_message "正在写入配置文件..." "$GREEN"

# 将ws-plugin/config/default_config/下的ws-config.yaml复制到ws-plugin/config/config/
cp ./plugins/ws-plugin/config/default_config/ws-config.yaml ./plugins/ws-plugin/config/config/

# 等待用户输入连接名称，链接地址和Token，机器人QQ
read -p "请输入您的连接名称(默认chronocat)：" name
read -p "请输入您的链接地址(默认127.0.0.1:16530)：" url
read -p "请输入您的Token：" token
read -p "请输入您的机器人QQ号：" uin

# 检查用户输入是否合法，如果不输入则使用默认值
if [ -z "$name" ]; then
  name="chronocat"
fi

if [ -z "$url" ]; then
  url="127.0.0.1:16530"
fi

if [[ "$url" == "http://"* ]]; then
    url=${url/http:\/\//}
fi

if [ -z "$token" ]; then
  echo "请输入您的Token"
  exit 1
fi

if [ -z "$uin" ]; then
  echo "请输入您的机器人QQ号"
  exit 1
fi

# 将用户输入的连接名称，链接地址和Token写入ws-plugin/config/config/ws-config.yaml
cat << EOF >> ./plugins/ws-plugin/config/config/ws-config.yaml
 
  - name: $name
    address: $url
    type: 4
    reconnectInterval: 5
    maxReconnectAttempts: 0
    accessToken: $token
    uin: $uin
EOF

# 如果是Miao-Yunzai，则提醒用户以后启动使用node apps启动
if [ "$version" == "2" ]; then
    print_message "请以后使用node apps启动Yunzai-Bot" "$YELLOW"
fi

print_message "配置成功，将在5秒后启动Yunzai-Bot" "$GREEN"

# 如果是TRSS-Yunzai，则使用node app启动，否则使用node apps启动
if [ "$version" == "1" ]; then
    node app
else
    node apps
fi