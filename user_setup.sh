#!/bin/bash

# make sure we are in right directory
[ -f user_setup.sh ] || (echo "RUN FROM REPO ROOT PLS" && exit)

# install pacman packages
sudo pacman -S - < pacmanlist.txt

# install xorg confs
# - disables mouse acceleration
# - enables trackpad touch to click and natural scrolling
sudo cp xorgconf/* /etc/X11/xorg.conf.d/

# install yay packages
yay -S - < aurlist.txt

cd ..

# install yay AUR helper
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..


# install dots
git clone git@github.com:sk8ersteve/dotfiles.git
cd ~
ln -s git-repos/dotfiles/.config .config
ln -s git-repos/dotfiles/.local .local
ln -s git-repos/dotfiles/.profile .profile
ln -s git-repos/dotfiles/.profile .zprofile
mkdir -p .local/share/zsh

# install oh my zsh
CHSH="no" RUNZSH="no" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

