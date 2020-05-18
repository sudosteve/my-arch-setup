#!/bin/sh

# install yay packages
yay -S - < aurlist.txt

# install dots
mkdir -p ~/git-repos
cd ~/git-repos
git clone git@github.com:sk8ersteve/dotfiles.git
cd ~
ln -s git-repos/dotfiles/.config .config
ln -s git-repos/dotfiles/.local .local
ln -s git-repos/dotfiles/.profile .profile
ln -s git-repos/dotfiles/.profile .zprofile
mkdir -p .local/share/zsh
mkdir -p .local/share/gnupg

# install oh my zsh
CHSH="no" RUNZSH="no" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

