#!/bin/bash

ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
hwclock --systohc
vim /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo $HOSTNAME > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

echo "Set root password"
passwd

pacman --noconfirm --needed -S networkmanager dhcpcd
systemctl enable NetworkManager
systemctl enable dhcpcd

# add user
pacman --noconfirm --needed -S zsh
useradd -m -G wheel -s /bin/zsh $USER
echo "Set password for user $USER"
passwd $USER
pacman -S sudo
visudo

# graphics
pacman --noconfirm --needed -S xf86-video-intel bumblebee nvidia bbswitch
systemctl enable bumblebeed.service

pacman --noconfirm --needed -S grub os-prober
grub-install $DRIVE

exit
umount -a
reboot

