#!/bin/bash

alias pacn="sudo pacman --noconfirm --needed -S"
pacn () { sudo pacman --noconfirm --needed -S $@ ; }

pacn dialog wpa_supplicant
pacn xorg-server xorg-xinit 
pacn i3-gaps dmenu i3status noto-fonts
pacn terminator htop chromium
