#!/bin/sh

# make sure we are in right directory
[ -f setup.sh ] || (echo "RUN FROM REPO ROOT PLS" && exit)

# install pacman packages
pacman --noconfirm --needed -S - < pacmanlist.txt
read -p "Check"

# install xorg confs
# - disables mouse acceleration
# - enables trackpad touch to click and natural scrolling
cp conf/xorg/* /etc/X11/xorg.conf.d/

# install grub config
cp conf/grub /etc/default/grub

# install optimus configs
cp conf/optimus-manager/* /etc/optimus-manager/

# add user with zsh
USERNAME=$(dialog --stdout --inputbox "Enter your username" 10 50 --stdout)
pacman --noconfirm --needed -S zsh
useradd -m -G wheel -s /bin/zsh $USERNAME
echo "Set password for user $USERNAME"
passwd $USERNAME

sudo -u "$USERNAME" ./user_setup.sh
