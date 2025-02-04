#!/bin/bash

# First boot

### Mount / rw
mount -t proc /proc /proc
mount -o remount,rw /

### Install essential packages

cd /opt || exit
apk add --allow-untrusted ./*

### Basic OpenRC config

rc-update add devfs sysinit
rc-update add sysfs sysinit

rc-update add modules boot
rc-update add sysctl boot
rc-update add hostname boot
rc-update add bootmisc
rc-update add syslog boot

rc-update add cgroups default
rc-update add sshd default
rc-update add chronyd default
rc-update add dhcpcd default

rc-update add udev sysinit
rc-update add udev-trigger sysinit
rc-update add udev-settle sysinit
rc-update add udev-postmount default

rc-update add mount-ro shutdown
rc-update add killprocs shutdown
rc-update add savecache shutdown

### IWD

rc-update add dbus default
rc-update add iwd default

### Contents of `/etc/iwd/main.conf`
# ```
# [General]
# EnableNetworkConfiguration=True
#
# [Network]
# NameResolvingService=resolvconf
# ```

## Partition
sgdisk -e /dev/mmcblk0 // Move the secondary GPT header to the end of the SD card
sgdisk -d 1 /dev/mmcblk0 // Delete the root partition from the partition table
sgdisk -n 1:4096:+10G /dev/mmcblk0 // Recreate a larger root partition
sgdisk -t 1:0xEF00 /dev/mmcblk0 // Change the root partition type to EFI system
sgdisk -N 2 /dev/mmcblk0 // Create a second partition with the remaining SD card space
sgdisk -t 2:0700 /dev/mmcblk0 // Change the second partition type to Microsoft Basic Data
partprobe // Reload the partition table
resize2fs /dev/mmcblk0p1 // Resize the root fs to fill the partition
mkfs.exfat /dev/mmcblk0p2 // Create the ROMS partition
mkdir /mnt/ROMS // Create a ROMS mountpoint
mount -t exfat /dev/mmcblk0p2 /mnt/ROMS // Mount the ROMS partition

## User
adduser -g "MuOS" muos
adduser muos wheel
adduser muos video
adduser muos input
adduser muos audio

# Uncomment `permit persist :wheel` in `/etc/doas.conf`

# Enable `XDG_RUNTIME_DIR` for MuOS user in `~/.profile`
if [ -z "$XDG_RUNTIME_DIR" ]; then
	XDG_RUNTIME_DIR="/tmp/$(id -u)-runtime-dir"

	mkdir -pm 0700 "$XDG_RUNTIME_DIR"
	export XDG_RUNTIME_DIR
fi

### GPU and Retroarch
apk add mesa-egl mesa-gbm mesa-utils mesa-dri-gallium
