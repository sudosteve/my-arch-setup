#!/bin/bash

# Run this after the drive has been properly partitioned

source params.sh

mount $ROOT /mnt
swapon $SWAP

pacstrap /mnt base base-devel linux linux-firmware

mount $EFI /mnt/boot
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
hwclock --systohc
vim /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo $HOSTNAME > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

passwd

pacman --noconfirm --needed -S networkmanager dhcpcd
systemctl enable NetworkManager

pacman --noconfirm --needed -S grub os-prober
grub-install $DRIVE

exit
umount -a
reboot

