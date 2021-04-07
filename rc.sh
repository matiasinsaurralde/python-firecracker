#!/bin/sh

set -euf

echo "=== My Bash RC ==="

#mkdir -p /dev/pts
#mkdir -p /dev/shm

mount -t proc proc /proc -o nosuid,noexec,nodev
#mount -t sysfs sys /sys -o nosuid,noexec,nodev
#mount -t tmpfs run /run -o mode=0755,nosuid,nodev
##mount -t devtmpfs dev /dev -o mode=0755,nosuid
#mount -t devpts devpts /dev/pts -o mode=0620,gid=5,nosuid,noexec
#mount -t tmpfs shm /dev/shm -omode=1777,nosuid,nodev

/root/entropy.py

#echo "Overlay setup"
mkdir -p /overlay
/bin/mount -t tmpfs -o noatime,mode=0755 tmpfs /overlay
mkdir -p /overlay/root /overlay/work
/bin/mount -o noatime,lowerdir=/,upperdir=/overlay/root,workdir=/overlay/work -t overlay "overlayfs:/overlay/root" /mnt
mkdir -p /mnt/rom
pivot_root /mnt /mnt/rom

mount --move /rom/proc /proc
mount --move /rom/dev /dev

echo "Mounts"

ls /
ls /dev

mkdir -p /dev/pts
mkdir -p /dev/shm

#mount -t proc proc /proc -o nosuid,noexec,nodev
mount -t sysfs sys /sys -o nosuid,noexec,nodev
mount -t tmpfs run /run -o mode=0755,nosuid,nodev
#mount -t devtmpfs dev /dev -o mode=0755,nosuid
mount -t devpts devpts /dev/pts -o mode=0620,gid=5,nosuid,noexec
mount -t tmpfs shm /dev/shm -omode=1777,nosuid,nodev


sleep 0.5
sync

ip addr add 172.16.0.2/24 dev eth0
ip link set eth0 up
ip route add default via 172.16.0.1 dev eth0
sync

ip addr

echo "Net up"

/root/entropy.py

#/usr/sbin/sshd -d -E /var/log/sshd &
/usr/sbin/sshd -E /var/log/sshd &

echo "SSH UP"

python3 --version
# Replace this script with the manager
exec /root/manager.py
