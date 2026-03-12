#!/bin/bash

# 生成随机端口号和密码
random_port=$((1024 + RANDOM % (9999 - 1024 + 1)))
random_password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 ; echo '')

# 更新并安装 snapd
echo "正在更新系统并安装 snapd..."
sudo apt update && sudo apt install -y snapd

# 安装 core snap
echo "安装 core..."
sudo snap install core

# 安装 shadowsocks-rust
echo "安装 shadowsocks-rust..."
sudo snap install shadowsocks-rust

# 创建配置文件目录
echo "创建配置文件目录..."
sudo mkdir -p /var/snap/shadowsocks-rust/common/etc/shadowsocks-rust/

# 创建并写入配置文件
CONFIG_FILE="/var/snap/shadowsocks-rust/common/etc/shadowsocks-rust/config.json"
echo "写入 shadowsocks-rust 配置文件..."

sudo tee $CONFIG_FILE > /dev/null <<EOL
{
    "server": "0.0.0.0",
    "server_port": $random_port,
    "local_port": 1080,
    "password": "$random_password",
    "method": "aes-256-gcm",
    "mode": "tcp_and_udp",
    "fast_open": false
}
EOL

# 启动并启用 shadowsocks-rust 服务
echo "启动 shadowsocks-rust 服务..."
sudo snap start --enable shadowsocks-rust.ssserver-daemon

# 检验 shadowsocks-rust 服务状态
echo "检验 shadowsocks-rust 服务状态..."
snap services shadowsocks-rust

# 检查服务是否运行成功
if snap services shadowsocks-rust | grep "shadowsocks-rust.ssserver-daemon" | grep "active"; then
    echo "shadowsocks-rust 安装并运行成功！"

    # 获取服务器公网 IP
    server_ip=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me || hostname -I | awk '{print $1}')

    # 生成 SIP002 标准 ss:// 链接
    # 格式: ss://base64(method:password)@server:port#remark
    userinfo=$(echo -n "aes-256-gcm:${random_password}" | base64 -w 0)
    remark=$(echo -n "MyServer" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read()))")
    ss_link="ss://${userinfo}@${server_ip}:${random_port}#${remark}"

    echo ""
    echo "============================================"
    echo "  Shadowsocks 配置信息"
    echo "============================================"
    echo "  服务器地址: $server_ip"
    echo "  服务器端口: $random_port"
    echo "  密码:       $random_password"
    echo "  加密方式:   aes-256-gcm"
    echo "--------------------------------------------"
    echo "  SIP002 链接:"
    echo "  $ss_link"
    echo "============================================"
else
    echo "shadowsocks-rust 服务未成功启动，请检查日志。"
    echo "可使用以下命令查看日志: sudo snap logs shadowsocks-rust.ssserver-daemon"
fi
