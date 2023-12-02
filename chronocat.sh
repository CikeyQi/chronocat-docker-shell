#!/bin/bash

# 添加颜色变量
RED="\e[31m"           # 红色
GREEN="\e[32m"         # 绿色
YELLOW="\e[33m"        # 黄色
RESET="\e[0m"          # 重置颜色

# 函数：检查端口是否合法且被占用
check_port() {
    local port=$1
    
    # 检查端口是否是一个正整数
    if ! [[ $port =~ ^[0-9]+$ ]]; then
        echo "错误：端口号必须是一个正整数。"
        exit 1
    fi
    
    # 检查端口范围
    if [ $port -lt 1 ] || [ $port -gt 65535 ]; then
        echo "错误：端口号必须在1和65535之间。"
        exit 1
    fi
    
    # 检查端口是否被占用
    ss -nlt | awk '{print $4}' | grep -q ":$port$"
    if [ $? -eq 0 ]; then
        echo "错误：端口号 $port 已经被占用。"
        exit 1
    fi
    
    # 检查非安全端口
    if [ $port -lt 1024 ]; then
        echo "警告：端口号 $port 是非安全端口。"
    fi
}

# 获取用户输入的端口号
read -p "请输入noVNC服务端口号: " port1
read -p "请输入Red服务端口号: " port2
read -p "请输入Satori服务端口号: " port3

# 检查端口号是否合法且被占用
check_port $port1
check_port $port2
check_port $port3

# 将端口号赋值给变量
VNCPORT=$port1
RedPORT=$port2
SatoriPORT=$port3

echo "端口号验证通过。"
echo "noVNC服务端口号: $VNCPORT"
echo "Red服务端口号: $RedPORT"
echo "Satori服务端口号: $SatoriPORT"

# 检查是否安装 Docker
if ! command -v docker &> /dev/null; then
    print_message "未检测到 Docker 环境，开始安装 Docker..." "$YELLOW"

    if command -v apt &> /dev/null; then
        apt update > /dev/null
        apt install -y docker.io > /dev/null
    elif command -v apt-get &> /dev/null; then
        apt-get update > /dev/null
        apt-get install -y docker.io > /dev/null
    elif command -v dnf &> /dev/null; then
        dnf install -y docker > /dev/null
        systemctl enable --now docker > /dev/null
    elif command -v yum &> /dev/null; then
        yum install -y docker-ce > /dev/null
        systemctl enable --now docker > /dev/null
    elif command -v pacman &> /dev/null; then
        pacman -Syu --noconfirm docker > /dev/null
        systemctl enable --now docker > /dev/null
    else
        print_message "无法确定操作系统的包管理器，请手动安装 Docker" "$RED"
        exit 1
    fi
    print_message "Docker 环境安装完成" "$GREEN"
else
    print_message "已安装 Docker 环境，跳过安装" "$GREEN"
fi

echo "正在拉取ChronoCat容器..."

docker pull he0119/chronocat-docker

read -p "请输入VNC服务密码: " password

echo "正在启动ChronoCat容器..."

docker run -it -p $RedPORT:16530 -p $VNCPORT:80 -p $SatoriPORT:5901 -e VNC_PASSWD=$password he0119/chronocat-docker