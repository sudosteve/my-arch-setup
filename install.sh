#!/bin/bash

# Run this after the drive has been properly partitioned

source params.sh

mount $ROOT /mnt
swapon $SWAP

# pacstrap /mnt base base-devel linux linux-firmware

mount $EFI /mnt/boot
genfstab -U /mnt >> /mnt/etc/fstab

cp chroot_install.sh /mnt/install.sh
arch-chroot /mnt ./install.sh
rm /mnt/install.sh

umount -a
reboot

