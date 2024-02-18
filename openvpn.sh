#!/bin/bash -e

TMP_DIR="/home/tmp/"
OPENVPN_VERSION="2.5.1"

install_dependencies() {
    sudo apt update
    sudo apt install -y gcc make liblz4-dev libssl-dev liblzo2-dev libpam0g-dev
}

create_directory() {
    if [ ! -d "$TMP_DIR" ]; then
        mkdir -p "$TMP_DIR"
    fi
}

download_and_install_openvpn() {
    cd "$TMP_DIR"
    wget "https://swupdate.openvpn.org/community/releases/openvpn-$OPENVPN_VERSION.tar.gz"
    tar -zxvf "openvpn-$OPENVPN_VERSION.tar.gz"
    cd "openvpn-$OPENVPN_VERSION/"
    ./configure && make -j$(nproc) && sudo make install
}

install_openvpn_manager() {
    sudo apt install -y openvpn network-manager-openvpn network-manager-openvpn-gnome
    sudo systemctl restart NetworkManager
    sudo reboot
}

if [ -f /etc/lsb-release ]; then
    source /etc/lsb-release
    if [ "$DISTRIB_ID" == "Ubuntu" ]; then
        install_dependencies
        create_directory
        download_and_install_openvpn
        install_openvpn_manager
    elif [ "$DISTRIB_ID" == "CentOS" ]; then
        create_directory
        yum install -y epel-release
        yum update -y
        yum install -y lz4-devel.x86_64 pam-devel.x86_64 wget curl openssl-devel NetworkManager-openvpn-gnome lzo-devel
        download_and_install_openvpn
        rm -rf "$TMP_DIR"
        reboot
    else
        echo "Other Linux distribution"
    fi
elif [ -f /etc/redhat-release ]; then
    if grep -q "CentOS" /etc/redhat-release; then
        create_directory
        yum install -y epel-release
        yum update -y
        yum install -y lz4-devel.x86_64 pam-devel.x86_64 wget curl openssl-devel NetworkManager-openvpn-gnome lzo-devel
        download_and_install_openvpn
        rm -rf "$TMP_DIR"
        reboot
    elif grep -q "Fedora" /etc/redhat-release; then
        echo "Fedora"
    else
        echo "Other Linux distribution"
    fi
else
    echo "Unknown Linux distribution"
fi
