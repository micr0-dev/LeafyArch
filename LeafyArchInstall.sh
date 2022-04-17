#!/bin/bash

echo "Establishing Connection..."
if ping -c 1 archlinux.org &> /dev/null; then
    echo "Connected!"
else
    echo "Unable to connect to the internet"
    exit 1
fi

echo "Cofiguring system clocks..."
timedatectl set-ntp true
echo "Complete!"