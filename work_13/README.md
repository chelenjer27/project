Цель домашнего задания
Диагностировать проблемы и модифицировать политики SELinux для корректной работы приложений.

Задание №1
Воспользуемся утилитой audit2allow для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу nginx на нестандартном порту: 
grep nginx /var/log/audit/audit.log | audit2allow -M nginx
[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:


semodule -i nginx.pp


[root@selinux ~]#


Audit2allow сформировал модуль, и сообщил нам команду, с помощью которой можно применить данный модуль: semodule -i nginx.pp


[root@selinux ~]# semodule -i nginx.pp && systemctl restart nginx

Также можно проверить работу nginx из браузера. Заходим в любой браузер на хосте и переходим по адресу http://127.0.0.1:4881

Задание №2

Решений два: первое, перенести файлы зон в каталог /var/named/ и изменить в конфигурации /etc/named.conf их расположение, второе можно изменить тип контекста безопаности для каталога /etc/named.

Используем решение №1 перемещяем каталог зоны.

Переместим все файлы и каталоги из /etc/named в /var/named: rsync -a /etc/named/ /var/named/ && rm -rf /etc/named/*

Восстанавливаем контекст безопасности рекурсивно в каталоге /var/named: restorecon -R /var/named

Изменим файл конфигурации /etc/named.conf, заменим расположение /etc/named/ на /var/named/: sed -i 's#/etc/named/#/var/named/#g' /etc/named.conf

Перечитаем  конфигурации сервиса named: systemctl reload named

Проверяем на клиенте возможность добавления новой А записи в зону ddns.lab:

[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www2.ddns.lab. 60 A 192.168.50.15
> send
> quit
[vagrant@client ~]$ dig @192.168.50.10 www2.ddns.lab    

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.10 <<>> @192.168.50.10 www2.ddns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 11786
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www2.ddns.lab.                 IN      A

;; ANSWER SECTION:
www2.ddns.lab.          60      IN      A       192.168.50.15

;; AUTHORITY SECTION:
ddns.lab.               3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10

;; Query time: 2 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Wed Dec 28 15:30:37 UTC 2022
;; MSG SIZE  rcvd: 97