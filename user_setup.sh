#!/bin/bash

source params.sh

# install all packages
./packages.sh

sudo cp xorgconf/* /etc/X11/xorg.conf.d/
sudo gpasswd -a $USER bumblebee

CHSH="no" RUNZSH="no" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


# install dots
cp -r dots/.* ~/

