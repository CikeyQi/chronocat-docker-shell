#!/bin/bash

# 函数：检查端口是否合法且被占用
check_port() {
    local port=$1
    
    # 检查端口是否是一个正整数
    if ! [[ $port =~ ^[0-9]+$ ]]; then
        echo "错误：端口号必须是一个正整数。"
        exit 1
    fi
    
    # 检查端口是否被占用
    ss -nlt | awk '{print $4}' | grep -q ":$port$"
    if [ $? -eq 0 ]; then
        echo "错误：端口号 $port 已经被占用。"
        exit 1
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