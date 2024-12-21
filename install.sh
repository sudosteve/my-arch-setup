#!/bin/sh

pacman -Sy --noconfirm dialog || { echo "Not running as root" ; exit; }

DISKS="$(lsblk -rpo "name,size,type,mountpoint" | awk '$3=="disk"{printf "%s (%s)\n", $1, $2}')"

# Pick a disk for installation
DISK="$(dialog --stdout --title "Choose for installation" --menu "Select which disk you would like to use for the installation" 10 70 4 $(echo $DISKS))"

# Ask if we want to partition a disk
dialog --defaultno --title "Partion disk?" --yesno "Would you like to open fdisk to partition the disk" 8 50 && ( clear ; fdisk $DISK ; sleep 1 )

# Select partitions for installation
getparts() { \
    lsblk -rpo "name,size,type,parttypename,mountpoint" | grep $1 | \
    awk '$3=="part"&&$5==""{printf "%s (%s)\n",$1,$2}'
}
getpart() { \
    [ -z "$(getparts $3)" ] || dialog --stdout --title "$1" \
    --menu "$2" 16 70 8 $(getparts $3)
}
EFI=$(getpart "efi partition" "Choose efi system partition" "EFI")
[ -z "$EFI" ] && clear && echo "No efi partitions found" && exit
ROOT=$(getpart "Root partition" "Choose a partition to install Arch on" "filesystem")
[ -z "$ROOT" ] && clear && echo "No filesystem partitions found for root" && exit
SWAP=$(getpart "Swap partition" "Choose swap partition" "swap")
[ -z "$SWAP" ] && clear && echo "No swap partitions found" && exit

# format partitions
EFIISFAT=$(lsblk -rpo "name,fstype" | grep $EFI | grep "vfat")
[ -z "$EFIISFAT" ] && echo "writing efi fs" && mkfs.fat -F32 $EFI
mkfs.ext4 $ROOT
mkswap $SWAP

# start installation
mount $ROOT /mnt
swapon $SWAP

KERNAL=""
read -p "Install linux-lts[y/N]: " choice
KERNAL+=$([[ $choice == y* ]] || [[ $choice == Y* ]] && echo "linux-lts linux-lts-headers ")
read -p "Install linux-zen[y/N]: " choice
KERNAL+=$([[ $choice == y* ]] || [[ $choice == Y* ]] && echo "linux-zen linux-zen-headers ")

pacstrap /mnt base base-devel linux linux-firmware linux-headers $KERNAL

mkdir /mnt/boot/EFI
mount $EFI /mnt/boot/EFI
genfstab -U /mnt >> /mnt/etc/fstab

curl -LO https://raw.githubusercontent.com/sk8ersteve/my-arch-setup/master/chroot_install.sh
chmod +x chroot_install.sh
cp chroot_install.sh /mnt/install.sh
read -p "About to enter chroot. Press enter to continue"
arch-chroot /mnt ./install.sh
rm /mnt/install.sh

read -p "Press enter to reboot"
reboot

