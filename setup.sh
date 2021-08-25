#!/bin/sh

# Make sure we are in right directory
[ -f setup.sh ] || (echo "RUN FROM REPO ROOT PLS" && exit)

# Install pacman packages
pacman --noconfirm --needed -S - < pacmanlist.txt
read -p "Check"

# Install xorg confs
# - disables mouse acceleration
# - enables trackpad touch to click and natural scrolling
cp conf/xorg/* /etc/X11/xorg.conf.d/

# Install pulse config
# - adds echo noise/cancellation
cp conf/default.pa /etc/pulse/

# install grub config
cp conf/grub /etc/default/grub

# add user with zsh
pacman --noconfirm --needed -S zsh
USERNAME=$(dialog --stdout --inputbox "Enter your username" 10 50 --stdout)
useradd -m -G wheel -s /bin/zsh $USERNAME
echo "Set password for user $USERNAME"
passwd $USERNAME

sudo -u "$USERNAME" ./user_setup.sh
