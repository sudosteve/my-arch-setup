#!/bin/sh

# install dots
mkdir -p ~/git-repos
cd ~/git-repos
git clone https://github.com/sk8ersteve/dotfiles.git
git clone https://github.com/sk8ersteve/my-arch-setup.git # optional
cd ~
ln -s git-repos/dotfiles/.config .config
ln -s git-repos/dotfiles/.local .local
ln -s git-repos/dotfiles/.profile .profile
ln -s git-repos/dotfiles/.profile .zprofile
# these folders must exist for some stuff to work
mkdir -p .local/share/zsh
mkdir -p .local/share/gnupg

# install yay AUR helper
cd ~/git-repos
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

# install yay packages
yay -S - < aurlist.txt

# install oh my zsh
cd ~/git-repos/my-arch-setup
CHSH="no" RUNZSH="no" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mv .oh-my-zsh ~/.config/oh-my-zsh
cp conf/a_custom.zsh-theme ~/.config/oh-my-zsh/custom/

# install my user directories
mkdir -p dl dox pix

