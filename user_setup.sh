#!/bin/sh

aurhelper=paru

cd ~

# Install dotfiles
git clone https://github.com/sk8ersteve/dotfiles.git
ln -s dotfiles/.config .config
ln -s dotfiles/.local .local
ln -s dotfiles/.profile .profile
ln -s dotfiles/.profile .zprofile
# These folders must exist for some stuff to work
mkdir -p .local/share/zsh
mkdir -p .local/share/gnupg

# Install AUR helper
git clone https://aur.archlinux.org/$aurhelper.git
cd $aurhelper
makepkg -si
cd ..
rm -rf $aurhelper

# install AUR packages
cd /tmp/my-arch-setup
$aurhelper -S - < aurlist.txt

# install oh my zsh
CHSH="no" RUNZSH="no" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mv ~/.oh-my-zsh ~/.config/oh-my-zsh
cd /tmp/my-arch-setup
cp conf/a_custom.zsh-theme ~/.config/oh-my-zsh/custom/

# install my user directories
cd ~
mkdir -p dl dox pix dev
cd ~

