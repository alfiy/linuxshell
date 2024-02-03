#!/bin/bash
# 更新源
sudo apt update && \
# 安装依赖
sudo apt install -y gcc make liblz4-dev libssl-dev liblzo2-dev libpam0g-dev && \
wait
# 进入下载目录
cd ~/Downloads/

# 下载openvpn源码包
wget https://swupdate.openvpn.org/community/releases/openvpn-2.5.1.tar.gz && \

# 解压源码包
tar -zxvf openvpn-2.5.1.tar.gz

# 进入源码目录
cd openvpn-2.5.1/

# 编译安装
./configure
wait
sudo make -j$(nproc)
wait
sudo make install

# 安装openvpn-manager
sudo apt install -y openvpn network-manager-openvpn network-manager-openvpn-gnome && \
sudo systemctl restart NetworkManager && \
sudo reboot
