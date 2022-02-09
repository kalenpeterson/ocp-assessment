# Increasing Worker node Disk space on CoreOS

## Notes

  * This procedure is for OCP 4.8+, and will be tested on 4.9
  * This is only for a UPI install. IPI will be done in the machine sets


## Procedure

See: https://access.redhat.com/discussions/6230831

### 1. Extend underlying Disk
Extend the disk allocated to each Worker node to desired size.

### 2. Connect to debug shell
```
oc debug no/<NODE_NAME> -n debug
chroot /host
```

### 3. Check the devices
```
lsblk
df -hP /
```

### 4. Grow filesystem
Run this on a node shell for each extended worker
```
sudo su
echo 1 >/sys/block/sda/device/rescan
growpart /dev/sda 4
sudo su -
unshare --mount
mount -o remount,rw /sysroot
xfs_growfs /sysroot
```

### 5. Check Filesystm
```
lsblk
df -hP /
```
