# Alpine Mainline

Create Alpine Linux SD card image for RG35XX, R36S with mainline kernel.

---

## Components:

| .   | Component    | System                      | Files                            |
| --- | ------------ | --------------------------- | -------------------------------- |
| 1   | Bootloader   | u-boot                      | u-boot-sunxi-with-spl.bin        |
| 2   | Device tree  | Linux                       | .dts/.dtb                        |
| 3   | Linux Kernel | Linux                       | Image                            |
| 4   | Modules      | Linux                       | /usr/lib/modules                 |
| 5   | Firmware     | Linux + vendors             | /usr/lib/firmware                |
| 6   | Rootfs       | buildroot / alpine / copied | /                                |
| 7   | SSH          | dropbear                    | ?                                |
| 8   | Wifi         | wpa_supplicant              | /etc/network/wpa_supplicant.conf |

### Device tree

### Linux Kernel

### Modules

### Firmware

### Rootfs

---

## Helper scripts

---

## Tools and debugging

1. fdisk/sgdisk
2. mkext4
3. menuconfig
4. fakeroot/userfish
5. podman
