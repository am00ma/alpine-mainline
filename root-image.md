# Root image creation script

## 1. Create an empty image file (2GB for example)

`$ dd if=/dev/zero of=./alpine-rg35xx.img bs=1M count=2048`

## 2. Mount as a loopback device and read partition table

```
# losetup -fP alpine-rg35xx.img
$ losetup --list
```

## 3. Create GPT partition table and ext4 root partition

Offset by 2MB (4096 sectors) rather than the standard 1MB (2048 sectors) to allow space for u-boot at high offset.
```
# sudo sgdisk -n 1:4096 /dev/loop20
# mkfs.ext4 /dev/loop20p1
```

## 4. Copy the Alpine rootfs, kernel image and modules to the ext4 partition

```
wget -c https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/aarch64/alpine-minirootfs-3.20.1-aarch64.tar.gz
mkdir rootfs
# tar -xvapf alpine-minirootfs-3.20.0-aarch64.tar.gz -C rootfs/ // run as root to preserve permissions
# mount /dev/loop20p1 /mnt
# cp -r rootfs/* /mnt
# cp -r apks /mnt/opt
# cp ~/<kernel_src>/arch/arm64/boot/Image /mnt
# cp -r ~/<INSTALL_MOD_PATH/lib/modules/* /mnt/lib/modules/

```
## 5. Pre-boot configuration

### Create an `/etc/fstab`



### Enable a getty on the serial port

Edit /etc/inittab in the rootfs and add the line:
```
# Put a getty on the serial port
#tyS0::respawn:/sbin/getty -L 115200 ttyS0 vt100
ttyS0::respawn:/sbin/getty -L ttyS0 115200 -n -l /bin/autologin
```

### Enable root login

`/mnt/bin/autologin`:

```
#!/bin/sh
/bin/login -f root
````

`# chmod +x /mnt/bin/autologin`

### Create a boot.scr script to load the kernel

```
echo -e "setenv bootargs console=tty0 console=ttyS0,115200 root=/dev/mmcblk0p1\nload mmc 0:1 \$kernel_addr_r Image\nbooti \$kernel_addr_r - \$fdtcontroladdr" > boot.cmd
~/<u_boot>/tools/mkimage -C none -A arm -T script -d boot.cmd boot.scr
# cp boot.scr /mnt
```

### Write the u-boot bootloader 

`sudo dd if=u-boot-sunxi-with-spl.bin of=/dev/loop20 bs=1k seek=256`

## 7. Unmount the loopback image (will also unmount mounted partitions)

`sudo losetup -d /dev/loop20`

## 8. Write the bootable image to an SD card

`sudo dd if=alpine-rg35xx.img of=/dev/sda bs=4M conv=fsync status=progress`

# First boot

### Mount / rw

mount -t proc /proc /proc
mount -o remount,rw /

### Install essential packages

cd /opt
apk add --allow-untrusted *

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
```
[General]
EnableNetworkConfiguration=True

[Network]
NameResolvingService=resolvconf
```
## Partition

```
# sgdisk -e /dev/mmcblk0 // Move the secondary GPT header to the end of the SD card
# sgdisk -d 1 /dev/mmcblk0 // Delete the root partition from the partition table
# sgdisk -n 1:4096:+10G /dev/mmcblk0 // Recreate a larger root partition
# sgdisk -t 1:0xEF00 /dev/mmcblk0 // Change the root partition type to EFI system
# sgdisk -N 2 /dev/mmcblk0 // Create a second partition with the remaining SD card space
# sgdisk -t 2:0700 /dev/mmcblk0 // Change the second partition type to Microsoft Basic Data
# partprobe // Reload the partition table
# resize2fs /dev/mmcblk0p1 // Resize the root fs to fill the partition
# mkfs.exfat /dev/mmcblk0p2 // Create the ROMS partition
# mkdir /mnt/ROMS // Create a ROMS mountpoint
# mount -t exfat /dev/mmcblk0p2 /mnt/ROMS // Mount the ROMS partition
```
## User

```
# adduser -g "MuOS" muos
# adduser muos wheel
# adduser muos video
# adduser muos input
# adduser muos audio
```

Uncomment `permit persist :wheel` in `/etc/doas.conf`

Enable `XDG_RUNTIME_DIR` for MuOS user in `~/.profile`

```
if [ -z "$XDG_RUNTIME_DIR" ]; then
	XDG_RUNTIME_DIR="/tmp/$(id -u)-runtime-dir"

	mkdir -pm 0700 "$XDG_RUNTIME_DIR"
	export XDG_RUNTIME_DIR
fi
```

### GPU and Retroarch

```
# apk add mesa-egl mesa-gbm mesa-utils mesa-dri-gallium
```
`
