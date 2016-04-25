#! /bin/bash

## ***********************************  ##
#   Yocto boot scripts for Android       #
## ************************************ ##

perm=$(id|cut -b 5)
if [ "$perm" != "0" ];then echo "This script requires root! Type: su"; exit; fi

export mnt=yocto-rootfs
export USER=root
export PATH=/bin:/usr/bin:/usr/local/bin:/usr/sbin:/bin:/usr/local/sbin:$PATH
#export HOME=/root

if [ $2 = "start" ]; then
	echo "Starting yocto chroot environment"
elif [ $2 = "stop" ]; then
	echo "Stoping yocto chroot environment"
	for f in dev/pts dev proc sys run ; do umount $mnt/$f ; done
	umount $mnt
	rm -rf yocto-rootfs
	exit
else
	echo "Invalid 2nd arg. Use either 'start' or 'stop'"
	exit
fi

mkdir yocto-rootfs
mount -t ext4 $1 yocto-rootfs


#This file is necessary to execute arm chroot in x86_64
if [ ! -f $mnt/usr/bin/qemu-arm-static ]; then
	cp /usr/bin/qemu-arm-static $mnt/usr/bin || { echo "No 'qemu-arm-static' found in host. Install it" ; exit 111; }
fi

#unbind and bind again
for f in dev dev/pts proc sys run ; do umount $mnt/$f ; done
for f in dev dev/pts proc sys run ; do mount -o bind /$f $mnt/$f ; done

echo "nameserver 8.8.8.8" > $mnt/etc/resolv.conf
echo "nameserver 8.8.4.4" >> $mnt/etc/resolv.conf
echo "127.0.0.1 localhost" > $mnt/etc/hosts
echo " "
chroot $mnt /bin/bash
