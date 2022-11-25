#!/bin/bash

#install zfs repo
  yum install -y http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
  #import gpg key 
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
  #install DKMS style packages for correct work ZFS
  yum install -y epel-release kernel-devel zfs
  #change ZFS repo
  yum-config-manager --disable zfs
  yum-config-manager --enable zfs-kmod
  yum install -y zfs
  #Add kernel module zfs
  modprobe zfs
  #install wget
  yum install -y wget
  #Создаём пул из  дисков в режиме RAID-1
  zpool create otus1 mirror /dev/sd{b,c}
  zpool create otus2 mirror /dev/sd{d,e}
  zpool create otus3 mirror /dev/sd{f,g}
  zpool create otus4 mirror /dev/sd{h,i}
  #Добавим разные алгоритмы сжатия в каждую файловую систему
  zfs set compression=lzjb otus1
  zfs set compression=lz4 otus2
  zfs set compression=gzip-9 otus3
  zfs set compression=zle otus4
  #Проверим, что все файловые системы имеют разные методы сжатия
  zfs get all | grep compression >> /home/vagrant/zpool_compresion.txt
  #Скачаем один и тот же текстовый файл во все пулы
  for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
  #Проверим, что файл был скачан во все пулы
  ls -l /otus* >> /home/vagrant/file_1.txt
  #Скачиваем архив снепшота
  wget -O archive.tar.gz https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg
  #Разархивируем архив
  tar -xzvf archive.tar.gz
  #Сделаем импорт данного пула
  zpool import -d zpoolexport/ otus
  #Работа со снапшотом, поиск сообщения от преподавателя
  wget -O otus_task2.file https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG
  #Восстановим файловую систему из снапшота
  zfs receive otus/test@today < otus_task2.file
  #Выполняем поиск файла
  find /otus/test -name "secret_message"
  #Читаем сообщение
  cat /otus/test/task1/file_mess/secret_message
  echo Homework completed