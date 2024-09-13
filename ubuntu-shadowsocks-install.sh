#!/bin/bash

# 生成随机端口号和密码
random_port=$((1024 + RANDOM % (9999 - 1024 + 1)))
random_password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 ; echo '')

#!/bin/bash

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

# 修改配置文件

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

# 检验 shadowsocks-rust 服务是否运行
echo "检验 shadowsocks-rust 服务状态..."
snap services shadowsocks-rust

# 检查服务是否运行成功
if snap services shadowsocks-rust | grep "shadowsocks-rust.ssserver-daemon" | grep "active"; then
    echo "shadowsocks-rust 安装并运行成功！"
    echo "Shadowsocks-Rust 安装配置成功，请牢记以下配置."
    echo "服务器端口: $random_port"
    echo "密码: $random_password"
    echo "加密: aes-256-gcm"
else
    echo "shadowsocks-rust 服务未成功启动，请检查日志。"
fi
