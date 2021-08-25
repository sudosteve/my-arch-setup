#!/bin/sh

pacman --noconfirm --needed -S dialog

# Prompt user for hostname, username
HOSTNAME=$(dialog --stdout --inputbox "Enter your hostname" 10 50 --stdout)
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
pacman --noconfirm --needed -S networkmanager dhcpcd
systemctl enable NetworkManager
systemctl enable dhcpcd

# Add perissions to sudoers file
echo "%wheel ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman,/usr/bin/paru" >> /etc/sudoers

# Sets up computer how I like it (optional)
pacman --noconfirm --needed -S git
mkdir -p /tmp
cd /tmp
git clone https://github.com/sk8ersteve/my-arch-setup.git
# Select branch
echo Select a branch to match your current machine [master]:
g branch | awk '{gsub("* ", ""); print $1};'
read
[ -z "$REPLY" ] && checkout $REPLY
cd my-arch-setup
sh setup.sh

# Install grub bootloader. Do this last because previous step copies grub.cfg
pacman --noconfirm --needed -S grub os-prober efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

exit

