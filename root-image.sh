#!/bin/bash

# -----------------------------------------------
# 1. Create an empty image file (2GB for example)
# -----------------------------------------------
dd if=/dev/zero of=./alpine-rg35xx.img bs=1M count=2048
# (Creates ./alpine-rg35xx.img)


# -----------------------------------------------
# 2. Mount as a loopback device and read partition table
# -----------------------------------------------
sudo losetup -fP alpine-rg35xx.img
# (No output)

losetup --list
# /dev/loop20         0      0         0  0 /home/x/hub/distributions/alpine-r36s/alpine-rg35xx.img   0     512


# -----------------------------------------------
# 3. Create GPT partition table and ext4 root partition
# -----------------------------------------------
sudo sgdisk -n 1:4096 /dev/loop20
# Creating new GPT entries in memory.
# The operation has completed successfully.

sudo mkfs.ext4 /dev/loop20p1
# mke2fs 1.47.0 (5-Feb-2023)
# Discarding device blocks: done                            
# Creating filesystem with 523771 4k blocks and 131072 inodes
# Filesystem UUID: 08b6e682-588d-4713-9217-610bdf799baa
# Superblock backups stored on blocks: 
# 	32768, 98304, 163840, 229376, 294912
#
# Allocating group tables: done                            
# Writing inode tables: done                            
# Creating journal (8192 blocks): done
# Writing superblocks and filesystem accounting information: done 

# -----------------------------------------------
# 4. Copy the Alpine rootfs, kernel image and modules to the ext4 partition
# -----------------------------------------------
mkdir rootfs
wget -c https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/aarch64/alpine-minirootfs-3.20.1-aarch64.tar.gz
# 2024-12-06 08:04:10 (2.84 MB/s) - ‘alpine-minirootfs-3.20.1-aarch64.tar.gz’ saved [3948433/3948433]

# Run as root to preserve permissions
sudo tar -xvapf alpine-minirootfs-3.20.1-aarch64.tar.gz -C rootfs/
sudo mount /dev/loop20p1 /mnt
sudo cp -r rootfs/* /mnt
sudo cp -r apks /mnt/opt
# BUG: cp: cannot stat 'apks': No such file or directory

# TODO: Copy built kernel and modules
# sudo cp ~/<kernel_src>/arch/arm64/boot/Image /mnt
# sudo cp -r ~/<INSTALL_MOD_PATH/lib/modules/* /mnt/lib/modules/

# -----------------------------------------------
# 5. Pre-boot configuration
# -----------------------------------------------

#   Create an `/etc/fstab`
#   ----------------------

#   Enable a getty on the serial port
#   ----------------------
# Edit /etc/inittab in the rootfs and add the line:
# Put a getty on the serial port
# tyS0::respawn:/sbin/getty -L 115200 ttyS0 vt100
echo 'ttyS0::respawn:/sbin/getty -L ttyS0 115200 -n -l /bin/autologin' >> rootfs/etc/inittab

#   Enable root login
#   ----------------------
# In `/mnt/bin/autologin`:
# #!/bin/sh
# /bin/login -f root

echo '#!/bin/sh'>             /mnt/bin/autologin
echo '  /bin/login -f root'>> /mnt/bin/autologin
chmod +x /mnt/bin/autologin

#   Create a boot.scr script to load the kernel
#   ----------------------
echo -e "setenv bootargs console=tty0 console=ttyS0,115200 root=/dev/mmcblk0p1\nload mmc 0:1 \$kernel_addr_r Image\nbooti \$kernel_addr_r - \$fdtcontroladdr" > boot.cmd
mkimage -C none -A arm -T script -d boot.cmd boot.scr
cp boot.scr /mnt


# -----------------------------------------------
# 6. Write the u-boot bootloader
# -----------------------------------------------
sudo dd if=u-boot-sunxi-with-spl.bin of=/dev/loop20 bs=1k seek=256

# -----------------------------------------------
# 7. Unmount the loopback image (will also unmount mounted partitions)
# -----------------------------------------------
sudo losetup -d /dev/loop20

# -----------------------------------------------
# 8. Write the bootable image to an SD card
# -----------------------------------------------
sudo dd if=alpine-rg35xx.img of=/dev/sda bs=4M conv=fsync status=progress

