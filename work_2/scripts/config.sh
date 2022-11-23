#!/bin/bash
            
            yum install -y mdadm smartmontools hdparm gdisk &&
            mdadm --create --verbose /dev/md10 -l 10 -n 10 /dev/sd{f,d,b,k,i,g,e,c,j,h} &&
            mkdir /etc/mdadm &&
            echo "DEVICE partitions" >/etc/mdadm/mdadm.conf &&
            mdadm --detail --scan --verbose | awk '/ARRAY/{print}'>>/etc/mdadm/mdadm.conf &&
            parted -s /dev/md10 mklabel gpt &&
            parted /dev/md10 mkpart primary ext4 0% 10% &&
            parted /dev/md10 mkpart primary ext4 10% 20% &&
            parted /dev/md10 mkpart primary ext4 20% 30% &&
            parted /dev/md10 mkpart primary ext4 30% 40% &&
            parted /dev/md10 mkpart primary ext4 40% 100% &&
            for i in $(seq 1 5);do sudo mkfs.ext4 /dev/md10p$i;done &&
            mkdir -p /raid/part{1,2,3,4,5} &&
            for i in $(seq 1 5);do mount /dev/md10p$i /raid/part$i;done
            #######mount###############
            if ! grep -q 'raid10' /etc/fstab ; 
            then
            echo '# raid10' >> /etc/fstab
            echo '/dev/md10p1    /raid/part1    ext4    defaults    0    2' >> /etc/fstab
            echo '/dev/md10p2    /raid/part2    ext4    defaults    0    2' >> /etc/fstab
            echo '/dev/md10p3    /raid/part3    ext4    defaults    0    2' >> /etc/fstab
            echo '/dev/md10p4    /raid/part4    ext4    defaults    0    2' >> /etc/fstab
            echo '/dev/md10p5    /raid/part5    ext4    defaults    0    2' >> /etc/fstab
            fi

