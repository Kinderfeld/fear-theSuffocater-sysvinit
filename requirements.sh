#!/bin/bash

clear

list_of_platforms() {
    DISTRIBUTIONS=(
        "void" "alpine" "gentoo" "dragora" "slackware"
        "fedora" "opensuse" "redhat" "freebsd" "netbsd" "openbsd"
        "arch" "artix" "manjaro" "hyperbola" "parabola"
        "debian" "ubuntu" "mint" "lmde" "trisquel" "devuan"
    )

    echo "Supported Platforms:"
    for ELEMENT in "${DISTRIBUTIONS[@]}"; do
        echo " - $ELEMENT"
    done
}

install_python_requirements() {
    python3 -m venv pkgenv
    source pkgenv/bin/activate
    pip install -r python_requirements.txt
    echo "Don't forget to 'source pkgenv/bin/activate' when you're ready to use the virtual environment."
}

install_debian_based() {
    apt update && apt upgrade -y
    apt install python3 python3-pip net-tools ufw iptables fail2ban openvpn nftables -y
}

install_arch_based() {
    pacman -Syu --noconfirm
    pacman -S python3 python3-pip net-tools ufw iptables fail2ban openvpn nftables --noconfirm
}

install_gentoo_based() {
    emerge --sync
    emerge -uDN @world
    emerge dev-python/pip
    echo "Gentoo setup is not fully implemented yet. Please install required packages manually."
}

install_alpine_based() {
    apk update && apk upgrade
    apk add python3 py3-pip net-tools ufw iptables fail2ban openvpn nftables
}

install_void_based() {
    xbps-install -S
    xbps-install python3 python3-pip net-tools ufw iptables fail2ban openvpn nftables
}

install_fedora_based() {
    dnf update -y
    dnf install python3 python3-pip net-tools firewalld fail2ban openvpn nftables -y
}

install_opensuse_based() {
    zypper refresh
    zypper install -y python3 python3-pip net-tools firewalld fail2ban openvpn nftables
}

install_slackware_based() {
    slackpkg update
    slackpkg install python3 python3-pip net-tools iptables fail2ban openvpn nftables
}


install_redhat_based() {
    yum update -y
    yum install python3 python3-pip net-tools firewalld fail2ban openvpn nftables -y
}

install_freebsd_based() {
    pkg update
    pkg install -y python3 py37-pip net-tools iptables fail2ban openvpn nftables
}

install_netbsd_based() {
    pkgin update
    pkgin install python37 py37-pip net-tools iptables fail2ban openvpn nftables
}

install_openbsd_based() {
    pkg_add python3 py3-pip net-tools pfctl fail2ban openvpn nftables
}

install_dragora_based() {
    pkg add python3 python3-pip net-tools ufw iptables fail2ban openvpn
}

to_lowercase() {
    echo "$1" | tr "[:upper:]" "[:lower:]"
}

main() {
    echo -n "Enter the base of your GNU/Linux or BSD distribution (Or type 'list' to view supported platforms): "
    read DISTRO

    if [[ "$DISTRO" == "list" ]]; then
        list_of_platforms
        main
        return
    fi

    echo "--------------------------------------------------------------------------------------"

    DISTRO=$(to_lowercase "$DISTRO")

    case "$DISTRO" in
        *debian*|*ubuntu*|*mint*|*lmde*|*trisquel*|*devuan*)
            install_debian_based
            ;;
        *arch*|*manjaro*|*hyperbola*|*parabola*|*artix*)
            install_arch_based
            ;;
        *gentoo*)
            install_gentoo_based
            ;;
        *alpine*)
            install_alpine_based
            ;;
        *void*)
            install_void_based
            ;;
        *fedora*)
            install_fedora_based
            ;;
        *opensuse*)
            install_opensuse_based
            ;;
        *slackware*)
            install_slackware_based
            ;;
        *redhat*)
            install_redhat_based
            ;;
        *freebsd*)
            install_freebsd_based
            ;;
        *netbsd*)
            install_netbsd_based
            ;;
        *openbsd*)
            install_openbsd_based
            ;;
        *dragora*)
            install_dragora_based
            ;;
        *)
            echo "Error: Unsupported distribution '$DISTRO'."
            exit 1
            ;;
    esac

    sleep 1
    clear
    echo -n "Now we need to create a virtual environment for Python3 in $(pwd). Do you wish to proceed? (y/n): "
    read ANSWER

    ANSWER=$(to_lowercase "$ANSWER")

    if [[ "$ANSWER" == "y" ]]; then
        install_python_requirements
    else
        exit 0
    fi
}

check_privileges() {
    if [ "$(id -u)" -eq 0 ]; then
        main
    else
        echo "This script requires root privileges to install packages."
        exit 1
    fi
}

check_privileges

