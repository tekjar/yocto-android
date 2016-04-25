##########################################
#Ubuntu boot script V5 for Android       #
#Built by Zachary Powell (zacthespack)   #
#Thanks to everyone at XDA!              #
##########################################
perm=$(id|cut -b 5)
if [ "$perm" != "0" ];then echo "This script requires root! Type: su"; exit; fi
mount -o remount,rw /dev/block/mmcblk0p5 /system
export kit=/sdcard/ubuntu
export bin=/system/bin
export mnt=/data/local/mnt
export USER=root
mkdir $mnt
export PATH=$bin:/usr/bin:/usr/local/bin:/usr/sbin:/bin:/usr/local/sbin:/usr/games:$PATH
export TERM=linux
export HOME=/root
if [ -b /dev/block/loop255 ]; then
	echo "Loop device exists"
else
	busybox mknod /dev/block/loop255 b 7 255
fi
#mount -o loop,noatime -t ext2 $kit/ubuntu.img $mnt
losetup /dev/block/loop255 $kit/ubuntu.img
mount -t ext2 /dev/block/loop255 $mnt
mount -t devpts devpts $mnt/dev/pts
mount -t proc proc $mnt/proc
mount -t sysfs sysfs $mnt/sys
busybox mount -o bind /sdcard $mnt/sdcard
busybox mount -o bind /sdcard/external_sd $mnt/external_sd
busybox sysctl -w net.ipv4.ip_forward=1
echo "nameserver 8.8.8.8" > $mnt/etc/resolv.conf
echo "nameserver 8.8.4.4" >> $mnt/etc/resolv.conf
echo "127.0.0.1 localhost" > $mnt/etc/hosts
echo "Ubuntu is configured with SSH and VNC servers that can be accessed from the IP:"
ifconfig eth0
echo " "
busybox chroot $mnt /root/init.sh

echo "Shutting down Ubuntu ARM"
umount $mnt/sdcard
umount $mnt/external_sd
umount $mnt/dev/pts
umount $mnt/proc 
umount $mnt/sys 
umount $mnt
losetup -d /dev/block/loop255
