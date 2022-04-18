#!/bin/bash

# Color Constants
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

echo "Establishing Connection..."
if ping -c 1 archlinux.org &> /dev/null; then
    echo -e "${Green}Connected!${White}"
else
    echo "Unable to connect to the internet"
    exit 1
fi

echo -e "\nCofiguring system clocks..."
timedatectl set-ntp true
echo -e "${Green}Complete!${White}\n"

while true; do
    lsblk
    echo -e -n "${Cyan}Please choose disk for installation:${White} (sda, nvme0n1, etc.) "
    read selectedDisk
    selectedDisk="/dev/$selectedDisk"
    echo -e -n "Are you sure you would like to use $selectedDisk? ${Red}It will be completly wiped and ALL DATA WILL BE LOST${White} (y/n) "
    read diskConfirmation
    case $diskConfirmation in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo -e "${Red}Please answer yes or no.\n${White}";;
    esac
done

isSSD="n"
echo "$selectedDisk" | grep -q 'nvme' &> /dev/null
if [ $? == 0 ]; then
   isSSD="y"
fi

echo -e "\nDisk $selectedDisk partitions: "
sfdisk -l $selectedDisk

echo -e "\nWiping disk $selectedDisk..." 
wipefs -a $selectedDisk
echo -e "${Green}Complete!${White}"

echo -e "\nDisk $selectedDisk partitions: "
sfdisk -l $selectedDisk

echo -e "\nPartitioning disk..." 
echo -e "n\n\n\n+512M\nt\n1\nn\n\n\n+2G\nt\n2\n19\nn\n\n\n\nw\n" | fdisk $selectedDisk
echo -e "${Green}Complete!${White}"

echo -e "\nDisk $selectedDisk partitions: "
sfdisk -l $selectedDisk

echo -e "\nFormatting /mnt to ext4..." 

if isSSD == "n"; then
    mkfs.ext4 -q "$selectedDisk3"
else
    mkfs.ext4 -q "$selectedDiskp3"
fi

echo -e "${Green}Complete!${White}"

echo -e "\nFormatting /mnt/boot to fat32..." 

if isSSD == "n"; then
    mkfs.fat -F 32 -q "$selectedDisk1"
else
    mkfs.fat -F 32 -q "$selectedDiskp1"
fi

echo -e "${Green}Complete!${White}"

echo -e "\nFormatting [SWAP] to swap..." 

if isSSD == "n"; then
    mkswap -q "$selectedDisk2"
else
    mkswap -q "$selectedDiskp2"
fi

echo -e "${Green}Complete!${White}"

echo -e "\nMounting System..." 

if isSSD == "n"; then
    mount "$selectedDisk3" /mnt 
    mount --mkdir "$selectedDisk1" /mnt/boot
    swapon "$selectedDisk2"
else
    mkswap "$selectedDiskp2"
fi

echo -e "${Green}Complete!${White}"

echo -e "\nInstalling essential Arch packages..."
pacstrap /mnt base linux linux-firmware
echo -e "${Green}Complete!${White}"

echo -e "\nGenerating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
echo -e "${Green}Complete!${White}"

echo -e "\n Changing root to /mnt..."
arch-chroot /mnt
