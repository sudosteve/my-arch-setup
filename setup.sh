#!/bin/sh

# Make sure we are in right directory
[ -f setup.sh ] || (echo "RUN FROM REPO ROOT PLS" && exit)

# Install pacman config with 32bit support
cp conf/pacman.conf /etc/pacman.conf
pacman -Sy --noconfirm archlinux-keyring

# Select graphics drivers to install
graphicspkg=""

# AMDGPU
read -p "Install amd graphics[y/N]: " choice
graphicspkg+=$([[ $choice == y* ]] || [[ $choice == Y* ]] &&
    echo "xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon mesa lib32-mesa ")

# Intel graphics
read -p "Install intel graphics[y/N]: " choice
graphicspkg+=$([[ $choice == y* ]] || [[ $choice == Y* ]] &&
    echo "xf86-video-intel ")

# Nvidia graphics
read -p "Install nvidia graphics?[y/N]: " choice
graphicspkg+=$([[ $choice == y* ]] || [[ $choice == Y* ]] &&
    echo "nvidia nvidia-utils lib32-nvidia-utils " &&
    [ -n "$(pacman -Q linux-lts)" ] && echo "nvidia-lts ")

pacman --noconfirm --needed -S $graphicspkg

# Install pacman packages
pacman --noconfirm --needed -S - < pacmanlist.txt

# Install xorg confs
# - disables mouse acceleration
# - enables trackpad touch to click and natural scrolling
cp conf/xorg/* /etc/X11/xorg.conf.d/

# Install grub config
cp conf/grub /etc/default/grub

# add user with zsh
pacman --noconfirm --needed -S zsh
USERNAME=$(dialog --stdout --inputbox "Enter your username" 10 50 --stdout)
useradd -m -G wheel -s /bin/zsh $USERNAME
echo "Set password for user $USERNAME"
passwd $USERNAME

sudo -u "$USERNAME" ./user_setup.sh
