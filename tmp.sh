#!/usr/bin/env bash

set -euo pipefail
trap 'echo "Error occurred. Exiting."; exit 1' ERR

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

require_root() {
    [[ $EUID -ne 0 ]] && echo -e "${RED}Run as root (sudo).${NC}" && exit 1
}

check_arch() {
    command -v pacman >/dev/null 2>&1 || {
        echo -e "${RED}This script must be run on Arch Linux.${NC}"
        exit 1
    }
}

enable_network() {
    pacman -S --noconfirm networkmanager
    systemctl enable NetworkManager
}

select_desktop() {

    echo -e "${YELLOW}Select Desktop Environment:${NC}"
    echo "1) GNOME"
    echo "2) KDE Plasma"
    echo "3) XFCE (Modern Setup)"
    echo "4) i3"
    echo "5) Cancel"
    read -rp "Choice: " choice

    case $choice in
        1)
            pacman -S --noconfirm gnome gdm
            systemctl enable gdm
            ;;
        2)
            pacman -S --noconfirm plasma-meta kde-applications sddm
            systemctl enable sddm
            ;;
        3)
            install_modern_xfce
            ;;
        4)
            pacman -S --noconfirm i3 i3status dmenu lightdm lightdm-gtk-greeter
            systemctl enable lightdm
            ;;
        *)
            echo "Cancelled."
            exit 0
            ;;
    esac
}

install_modern_xfce() {

    pacman -S --noconfirm \
        xfce4 xfce4-goodies \
        lightdm lightdm-gtk-greeter \
        arc-gtk-theme \
        papirus-icon-theme \
        nordic-theme \
        picom \
        plank \
        ttf-jetbrains-mono \
        noto-fonts \
        ttf-dejavu

    systemctl enable lightdm

    read -rp "Enter your username: " USERNAME

    CONFIG_DIR="/home/$USERNAME/.config"

    mkdir -p "$CONFIG_DIR/gtk-3.0"
    mkdir -p "$CONFIG_DIR/autostart"

    # Modern GTK theme
    cat > "$CONFIG_DIR/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=Nordic
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=JetBrains Mono 10
gtk-application-prefer-dark-theme=1
EOF

    # Autostart plank
    cat > "$CONFIG_DIR/autostart/plank.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank
EOF

    chown -R "$USERNAME:$USERNAME" "$CONFIG_DIR"

    echo -e "${GREEN}Modern XFCE installed successfully.${NC}"
}

main() {
    require_root
    check_arch

    echo -e "${GREEN}Arch Post-Install Desktop Setup${NC}"

    enable_network
    select_desktop

    echo -e "${GREEN}Done. Reboot to start your desktop.${NC}"
}

main
