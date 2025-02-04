# alpine-mainline

Steps:

## Create SD card

1. Create an empty image file (2GB for example)
    - inputs: -
    - outputs: `alpine-rg35xx.img`
    - debug: `fdisk -l alpine-rg35xx.img`
2. Mount as a loopback device and read partition table
    - inputs: `alpine-rg35xx.img`
    - outputs: `/dev/loopXX`
    - debug: `losetup --list`, `echo "Use: umount; losetup --detach /dev/loopXX"`
3. Create GPT partition table and ext4 root partition
    - inputs: `/dev/loopXX`
    - outputs: `/dev/loopXXp1`
4. Download and unzip alpine-minirootfs
    - inputs: `alpine-minirootfs-3.20.1-aarch64.tar.gz`, `/dev/loopXXp1`
    - outputs: `rootfs`
    - debug: `ls rootfs`
5. Copy the Alpine rootfs
    - inputs: `/dev/loopXXp1`, `rootfs`, `apks`
    - outputs: `/mnt`
    - debug: `ls /mnt`
6. kernel image and modules to the ext4 partition
    - inputs: `/dev/loopXXp1`, `Image`, `modules`
    - outputs: `/mnt`
    - debug: `file /mnt/Image`, `ls /mnt/lib/modules`
7. Pre-boot configuration
    - Create an `/etc/fstab`
        - inputs: `fstab`
        - outputs: `/mnt/etc/fstab`
        - debug: `cat /mnt/etc/fstab`
    - Enable a getty on the serial port
        - inputs: `ttyXX`, `baud_rate`, `autologin`
        - outputs: `/mnt/etc/inittab`
        - debug: `cat /mnt/etc/inittab`
    - Enable root login
        - inputs: `/mnt/bin/sh`, `/mnt/bin/login`
        - outputs: `/mnt/bin/autologin`
        - debug: `cat /mnt/bin/autologin`
8 Create a boot.scr script to load the kernel
    - inputs: `boot.cmd`
    - outputs: `/mnt/boot.scr`
    - debug: `cat /mnt/boot.scr`
9. Write the u-boot bootloader
    - inputs: `u-boot-sunxi-with-spl.bin`, `/dev/loopXX`
    - outputs: `/dev/loopXX`
    - debug: `fdisk -l alpine-rg35xx.img`
10. Unmount the loopback image (will also unmount mounted partitions)
    - inputs: `/dev/loopXX`, `/mnt`
    - outputs: `/dev/loopXX`, `/mnt`
    - debug: `losetup --list`, `ls /mnt`
11. Write the bootable image to an SD card
    - inputs: `alpine-rg35xx.img`, `/dev/sda`
    - outputs: `/dev/sda`
    - debug: `fdisk -l /dev/sda`

## First boot

1. Mount / rw
    - inputs: `/proc`
    - outputs: `/proc`
    - debug: `ls /proc`
2. Install essential packages
    - inputs: `/opt`
    - outputs: `/opt`
    - debug: `ls /opt`
3. Basic OpenRC config
    - inputs: -
    - outputs: -
    - debug: `rc-update list`?
4. IWD
    - inputs: -
    - outputs: -
    - debug: `rc-update show iwd`?
5. Contents of `/etc/iwd/main.conf`
    - inputs: -
    - outputs: `/etc/iwd/main.conf`
    - debug: `cat /etc/iwd/main.conf`?
6. Partition
    - inputs: `/dev/mmcblk0`
    - outputs: `/dev/mmcblk0`, `/dev/mmcblk0p1`, `/dev/mmcblk0p2`, `/mnt/ROMS`
    - debug: `ls /dev/mmcblk0`?
7. User
    - inputs: -
    - outputs: `/etc/doas.conf`, `~/.profile`
    - debug: `cat /etc/doas.conf | grep "permit persist"`, `adduser list`?
8. GPU and Retroarch
    - inputs: -
    - outputs: -
    - debug: `apk list`?
