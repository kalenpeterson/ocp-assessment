# Increasing Worker node Disk space on CoreOS

## Notes

  * This procedure is for OCP 4.8+, and will be tested on 4.9
  * This is only for a UPI install. IPI will be done in the machine sets


## Procedure

See: https://access.redhat.com/discussions/6230831

### 1. Extend underlying Disk
Extend the disk allocated to each Worker node to desired size.

### 2. Grow filesystem
Run this on a node shell for each extended worker
```
sudo su
growpart /dev/sda 4
sudo su -
unshare --mount
mount -o remount,rw /sysroot
xfs_growfs /sysroot
```

