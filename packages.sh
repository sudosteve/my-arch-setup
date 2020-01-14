#!/bin/bash

# pacman packages

pacn () { sudo pacman --noconfirm --needed -S $@ ; }

pacn dialog wpa_supplicant
pacn xorg-server xorg-xinit xorg-xsetroot
pacn alsa-utils tlp
pacn i3-gaps dmenu network-manager-applet i3status noto-fonts feh
pacn htop openssh man wget curl
pacn qutebrowser chromium rxvt-unicode

# install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..

# yay packages

yay -S pywal-git
yay -S dina-font-ttf

