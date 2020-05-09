#!/bin/bash

ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo $HOSTNAME > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

echo "Set root password"
passwd

# Network Manager
pacman --noconfirm --needed -S networkmanager
# Try without dhcpcd because I'm still not sure what arch installs by default
# pacman --noconfirm --needed -S networkmanager dhcpcd
systemctl enable NetworkManager
# systemctl enable dhcpcd

# add user with zsh
pacman --noconfirm --needed -S zsh
useradd -m -G wheel -s /bin/zsh $USER
echo "Set password for user $USER"
passwd $USER
pacman -S sudo
visudo

# graphics
pacman --noconfirm --needed -S xf86-video-intel bumblebee nvidia bbswitch
systemctl enable bumblebeed.service

# install grub bootloader
pacman --noconfirm --needed -S grub os-prober
grub-install $DRIVE
grub-mkconfig -o /boot/grub/grub.cfg

exit
umount -a
reboot

