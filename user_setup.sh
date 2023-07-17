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

# Set default rust version
rustup default nightly

# Install AUR helper
git clone https://aur.archlinux.org/$aurhelper.git
cd $aurhelper
makepkg --noconfirm -si
cd ..
rm -rf $aurhelper

cd /tmp/my-arch-setup

# Install optimus-manager
read -p "Install optimus-manager?[y/N]: " choice
if [[ $choice == y* ]] || [[ $choice == Y* ]]
then
    $aurhelper --noconfirm --needed -S optimus-manager
    sudo cp -r conf/optimus-manager /etc/
fi

# Install AUR packages
$aurhelper --noconfirm --needed -S - < aurlist.txt

# Install oh my zsh
CHSH="no" RUNZSH="no" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mv ~/.oh-my-zsh ~/.config/oh-my-zsh
cp conf/a_custom.zsh-theme ~/.config/oh-my-zsh/custom/

cd ~

# Install my user directories
mkdir -p dl dox pix dev

