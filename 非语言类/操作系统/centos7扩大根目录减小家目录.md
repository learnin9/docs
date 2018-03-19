```auto
# mkdir -p /backup

# cp -r /home/* /backup

# umount /home

#  df -hl

# fdisk -l

# lvremove /dev/centos/home

# vgdisplay

# lvcreate -L 5G -n home centos

# lvdisplay

# vgdisplay

# vgchange -ay centos

# mkfs -t xfs /dev/centos/home

# mount /dev/centos/home /home/

# lvextend -L +36G /dev/centos/root

# vgchange -ay centos

# xfs_growfs /dev/centos/root

# df -hl
```