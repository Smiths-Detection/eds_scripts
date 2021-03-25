#!/bin/sh

none_removable_disk()
{
    [ "$(cat /sys/block/$1/removable)0" == 00 ]
}


create_vg()
{
   umount -f /home/ctxdata

   lvm lvremove /dev/ctxdata/datadisk0 -f --yes
   lvm vgremove /dev/ctxdata -f --yes

if none_removable_disk sdb ; then
    lvm pvremove /dev/sdb1 -f --yes
    parted /dev/sdb rm 1 -s
    parted /dev/sdb mklabel gpt -s
    parted /dev/sdb unit % mkpart logical 0 100 -s
    lvm pvcreate /dev/sdb1 -ff -y -v

    if none_removable_disk sdc ; then
        lvm pvremove /dev/sdc1 -f --yes
        parted /dev/sdc rm 1 -s
        parted /dev/sdc mklabel gpt -s
        parted /dev/sdc unit % mkpart logical 0 100 -s
        lvm pvcreate /dev/sdc1 -ff -y -v

        if none_removable_disk sdd ; then
            lvm pvremove /dev/sdd1 -f --yes
            parted /dev/sdd rm 1 -s
            parted /dev/sdd mklabel gpt -s
            parted /dev/sdd unit % mkpart logical 0 100 -s
            lvm pvcreate /dev/sdd1 -ff -y -v
            lvm vgcreate ctxdata /dev/sdb1 /dev/sdc1 /dev/sdd1 -s 128M -v --yes
        else
            lvm vgcreate ctxdata /dev/sdb1 /dev/sdc1 -s 128M -v --yes
        fi
    else
        lvm vgcreate ctxdata /dev/sdb1 -s 128M -v --yes
    fi

    
else
    echo "#ctxdata uses partition on /dev/sda" > /tmp/part-include
fi
}

create_r0()
{   
  lvm lvcreate ctxdata -n datadisk0 -l 100%VG -v --yes
	mkfs -t ext4 /dev/ctxdata/datadisk0
  mount /dev/ctxdata/datadisk0 /home/ctxdata
}

create_r1()
{   
  lvm lvcreate --type raid1 ctxdata -n datadisk0 -l 100%VG -v --yes
	mkfs -t ext4 /dev/ctxdata/datadisk0
  mount /dev/ctxdata/datadisk0 /home/ctxdata
}




echo "This script will rebuild x800 Host computer bag image storage disk array and convert to Raid 0 (strip) or Raid 1 (mirror). Make sure to backup bag images to external drive before proceeding!" 

while true; do

   read -p "Do you wish to continue? " yn

   case $yn in 
         [Yy]* ) while true; do
	
		read -p "WARNING: All bag image data stored will be lost!!! Please type 'yes' to confirm or Ctl+C to exit: " yo

           	case $yo in 

     		    [yes]* ) while true; do

                  	   read -p "Please enter rebuild type: 0=Raid0; 1=Raid1" rt

                  	   case $rt in 
                  	      [0]* ) create_vg; create_r0;exit;;
                  	      [1]* ) create_vg; create_r1;exit;;
    	 	  	       * ) exit;;
  		 	     esac
	                 done;;
	            [Nn]* ) exit;;
	            * ) echo "Please answer yes or no.";; 
           	 esac
		done
    esac
done
