#!/bin/bash




SECOND_PID=/var/run/httpd/httpd-second.pid
SECOND_LISTEN=8081
SECOND_SERVERNAME=second.local
FIRST_PID=/var/run/httpd/httpd-first.pid
FIRST_LISTEN=8080
FIRST_SERVERNAME=first.local
HTTPD_USER=apache
HTTPD_GROUP=apache
HTTPD_PATH_MODULES=conf.modules.d/*.conf


yum install -y epel-release 
yum install -y spawn-fcgi php php-cli mod_fcgid httpd
systemctl stop spawn-fcgi httpd


cat >/etc/sysconfig/watchlog<< EOF
# Configuration file for my watchdog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/messages
EOF


cat >/opt/watchlog.sh<< EOF
#!/bin/bash
WORD=\$1
LOG=\$2
DATE=\`date\`
if grep \$WORD \$LOG &> /dev/null
then
logger "\$DATE: I found word, Master!"
else
exit 0
fi
EOF


chmod +x /opt/watchlog.sh


cat >/etc/systemd/system/watchlog.service<< EOF
[Unit]
Description=My watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh \$WORD \$LOG
EOF


cat >/etc/systemd/system/watchlog.timer<< EOF
[Unit]
Description=Run watchlog script every 30 second
[Timer]
OnActiveSec=1sec
OnUnitActiveSec=30
AccuracySec=1us
Unit=watchlog.service
[Install]
WantedBy=multi-user.target
EOF


cat >/etc/sysconfig/spawn-fcgi<< EOF
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"
EOF


cat >/etc/systemd/system/spawn-fcgi.service<< EOF
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF


#sed '/#[SOCKET,OPTIONS]/s/^#//' -i /etc/sysconfig/spawn-fcgi


selinuxenabled && setenforce 0


cp /usr/lib/systemd/system/httpd.service /usr/lib/systemd/system/httpd@.service
cp /etc/mime.types /etc/httpd/conf
sed '/^Description/ s/$/ %I/' -i /usr/lib/systemd/system/httpd@.service
sed '/^EnvironmentFile/ s/$/-%I/' -i /usr/lib/systemd/system/httpd@.service


cat >/etc/sysconfig/httpd-first<< EOF
OPTIONS=-f conf/first.conf
EOF


cat >/etc/sysconfig/httpd-second<< EOF
OPTIONS=-f conf/second.conf
EOF


cat >/etc/httpd/conf/first.conf<< EOF
ServerName $FIRST_SERVERNAME
PidFile $FIRST_PID
Listen $FIRST_LISTEN
Include $HTTPD_PATH_MODULES
User $HTTPD_USER
Group $HTTPD_GROUP
EOF


cat >/etc/httpd/conf/second.conf<< EOF
ServerName $SECOND_SERVERNAME
PidFile $SECOND_PID
Listen $SECOND_LISTEN
Include $HTTPD_PATH_MODULES
User $HTTPD_USER
Group $HTTPD_GROUP
EOF


systemctl daemon-reload
systemctl start spawn-fcgi watchlog.timer httpd@first httpd@second