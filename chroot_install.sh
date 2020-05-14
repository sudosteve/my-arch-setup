#!/bin/bash

pacman --noconfirm --needed -S dialog

# Prompt user for hostname, username
HOSTNAME=$(dialog --stdout --inputbox "Enter your hostname" 10 50 --stdout)
USERNAME=$(dialog --stdout --inputbox "Enter your username" 10 50 --stdout)
clear

# locale setting
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# hostname settings
echo $HOSTNAME > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

echo "Set root password"
passwd

# Network Manager
pacman --noconfirm --needed -S networkmanager
pacman --noconfirm --needed -S networkmanager dhcpcd
systemctl enable NetworkManager
systemctl enable dhcpcd

# add user with zsh
pacman --noconfirm --needed -S zsh
useradd -m -G wheel -s /bin/zsh $USERNAME
echo "Set password for user $USERNAME"
passwd $USERNAME

# add perissions to sudoers file
echo "%wheel ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman,/usr/bin/yay" >> /etc/sudoers

# graphics
pacman --noconfirm --needed -S xf86-video-intel nvidia bbswitch

# install grub bootloader
DISK=$(cat disk.tmp)
pacman --noconfirm --needed -S grub os-prober efibootmgr
grub-install $DISK
grub-mkconfig -o /boot/grub/grub.cfg

exit

