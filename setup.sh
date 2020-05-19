#!/bin/sh

# make sure we are in right directory
[ -f setup.sh ] || (echo "RUN FROM REPO ROOT PLS" && exit)

# install pacman packages
sudo pacman -S - < pacmanlist.txt

# install xorg confs
# - disables mouse acceleration
# - enables trackpad touch to click and natural scrolling
sudo cp xorgconf/* /etc/X11/xorg.conf.d/

# install yay AUR helper
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# add user with zsh
USERNAME=$(dialog --stdout --inputbox "Enter your username" 10 50 --stdout)
pacman --noconfirm --needed -S zsh
useradd -m -G wheel -s /bin/zsh $USERNAME
echo "Set password for user $USERNAME"
passwd $USERNAME
touch /home/$USERNAME/.zshrc

sudo -u "$USERNAME" user_setup.sh
