#!/bin/sh

none_removable_disk()
{
    [ "$(cat /sys/block/$1/removable)0" == 00 ]
}


lvm lvremove /dev/ctxdata/datadisk0 -f --yes
lvm vgremove /dev/ctxdata -f --yes

if none_removable_disk sdb ; then
    lvm pvremove /dev/sdb1 -f --yes
    parted /dev/sdb rm 1 -s
    parted /dev/sdb mklabel gpt -s
    parted /dev/sdb unit % mkpart logical 0 100 -s
    lvm pvcreate /dev/sdb1 -ff -y -v --yes

    if none_removable_disk sdc ; then
        lvm pvremove /dev/sdc1 -f --yes
        parted /dev/sdc rm 1 -s
        parted /dev/sdc mklabel gpt -s
        parted /dev/sdc unit % mkpart logical 0 100 -s
        lvm pvcreate /dev/sdc1 -ff -y -v --yes

        if none_removable_disk sdd ; then
            lvm pvremove /dev/sdd1 -f --yes
            parted /dev/sdd rm 1 -s
            parted /dev/sdd mklabel gpt -s
            parted /dev/sdd unit % mkpart logical 0 100 -s
            lvm pvcreate /dev/sdd1 -ff -y -v --yes
            lvm vgcreate ctxdata /dev/sdb1 /dev/sdc1 /dev/sdd1 -s 128M -v --yes
        else
            lvm vgcreate ctxdata /dev/sdb1 /dev/sdc1 -s 128M -v --yes
        fi
    else
        lvm vgcreate ctxdata /dev/sdb1 -s 128M -v --yes
    fi

    lvm lvcreate ctxdata -n datadisk0 -l 100%VG -v --yes
    echo "logvol /home/ctxdata --vgname=ctxdata --fstype ext4 --name=datadisk0 --percent=100 --useexisting" > /tmp/part-include
else
    echo "#ctxdata uses partition on /dev/sda" > /tmp/part-include
fi

mkfs -t ext4 /dev/ctxdata/datadisk0
mount /dev/ctxdata/datadisk0 /home/ctxdata
