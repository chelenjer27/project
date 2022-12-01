# При выполнение ДЗ использовалось следуещие окружение: 
    ОС Ubuntu Desctop 22.04
    VirtualBox 6.1.38
    Vagrant 2.3.3
    Плагин vagrant-vbguest 0.21
# Смена пароля root 
# init=/bin/sh
 ля получения доступа необходимо открыть GUI VirtualBox, запустить виртуальную машину и при выборе ядра для загрузки нажать `e` - в данном контексте `edit`. Попадаем в окно где мы можем изменить параметры загрузки:
 ![ScreenshotMenu](https://github.com/chelenjer27/project/tree/main/work_7/screen/Screen1.png)
 Переходим стрелкой к строке, начинающейся с `linux16`, нажимаем `End` чтобы перейти курсором в конец строки и клавишой `Backspace` удаляем всё до параметра `root=UUID=<UUID>` и после добавляем `init=/bin/sh` (пример на скриншоте ниже) нажимаем `сtrl-x` для загрузки в систему
 Рутовая файловая система при этом монтируется в режиме `Read-Only`. Если вы хотите перемонтировать ее в режим `Read-Write` можно воспользоваться командой `mount -o remount,rw /`
После чего можно убедится записав данные в любой файл
 ![ScreenshotMenu](https://github.com/chelenjer27/project/tree/main/work_7/screen/Scrin_root.png)
# rd.break
В конце строки начинающейся с linux16 добавляем rd.break и нажимаем сtrl-x для
загрузки в систему
Попадаем в emergency mode. Наша корневая файловая система смонтирована (опять же
в режиме Read-Only, но мы не в ней. Далее будет пример как попасть в нее и поменять
пароль администратора:
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
touch /.autorelabel
После чего можно перезагружаться и заходить в систему с новым паролем. Полезно
когда вы потеряли или вообще не имели пароль
# rw init=/sysroot/bin/sh
В строке начинающейся с linux16 заменяем ro на rw init=/sysroot/bin/sh и нажимаем сtrl-x
для загрузки в систему
В целом то же самое что и в прошлом примере, но файловая система сразу
смонтирована в режим Read-Write
# Установить систему с LVM, после чего переименовать VG
Текущее состояние системы:
vgs
VG #PV #LV #SN Attr VSize VFree
VolGroup00 1 2 0 wz--n- <38.97g
Приступим к переименованию:
sudo vgrename VolGroup00 OtusRoot
правим /etc/fstab, /etc/default/grub, /boot/grub2/grub.cfg. Везде заменяем старое
название на новое.
Пересоздаем initrd image, чтобы он знал новое название Volume Group
sudo mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
После чего можем перезагружаться и если все сделано правильно успешно грузимся с
новым именем Volume Group и проверяем:
sudo vgs
Скрипты модулей хранятся в каталоге /usr/lib/dracut/modules.d/. Для того чтобы
добавить свой модуль создаем там папку с именем 01test:
sudo mkdir /usr/lib/dracut/modules.d/01test
В нее поместим два скрипта:
1.module-setup.sh - который устанавливает модуль и вызывает скрипт test.sh
2.test.sh - собственно сам вызываемый скрипт, в нём у нас рисуется пингвинчик
Пересобираем образ initrd
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
или
dracut -f -v
Можно проверить/посмотреть какие модули загружены в образ:
lsinitrd -m /boot/initramfs-$(uname -r).img | grep test
После чего можно пойти двумя путями для проверки:
○Перезагрузиться и руками выключить опции rghb и quiet и увидеть вывод
○Либо отредактировать grub.cfg убрав эти опции
В итоге при загрузке будет пауза на 10 секунд и вы увидите пингвина в выводе
терминала
![ScreenshotMenu](https://github.com/chelenjer27/project/tree/main/work_7/screen/Pingvin.png)