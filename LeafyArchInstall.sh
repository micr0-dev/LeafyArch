#!/bin/bash

echo "Establishing Connection..."
if ping -c 1 archlinux.org &> /dev/null; then
    echo "Connected!"
else
    echo "Unable to connect to the internet"
    exit 1
fi

echo -e "\nCofiguring system clocks..."
timedatectl set-ntp true
echo -e "Complete!\n"

while true; do
    lsblk
    read -p "Please choose disk for installation: (sda, nvme0n1, etc.)" selectedDisk
    selectedDisk="/dev/$selectedDisk"
    read -p "Are you sure you would like to use $selectedDisk? It will be completly wiped and ALL DATA WILL BE LOST (y/n) " diskConfirmation
    case $diskConfirmation in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo -e "Please answer yes or no.\n";;
    esac
done

echo -e "\nDisk $selectedDisk partitions: "
sfdisk -l $selectedDisk

echo -e "\nWiping disk $selectedDisk..." 
sfdisk --delete $selectedDisk
echo -e "Complete!"

echo -e "\nDisk $selectedDisk partitions: "
sfdisk -l $selectedDisk

#echo -e "\nCreating /boot..." 
#sfdisk --delete $selectedDisk
#echo -e "Complete!"