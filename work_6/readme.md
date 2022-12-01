# При выполнение ДЗ использовалось следуещие окружение: 
    ОС Ubuntu Desctop 22.04
    VirtualBox 6.1.38
    Vagrant 2.3.3
    Плагин vagrant-vbguest 0.21
# Скрипт автонастройки
  Скрипт находится в директории /project/work_4/script/config.sh
# Vagrandfile
  Копирование скрипта для гостевой VM
# Для запуска проекта и проверки выполнения дз № 4 необходимо выполнить следующие команды:
# Клонируем репозиторий
    1. git clone https://github.com/chelenjer27/project 
# Переходим в рабочий каталог проекта
    2. cd /project/work_6
# Запускаем виртуальную машину
    3. vagrant up
# Подключаемся к виртуальной машине
    4. vagrant ssh
# Запустить скрипт
    5. sudo bash ./home/vagrant/rpm_script.sh
# Проверяeм опубликованный репозиторий на NGINX
    6. lynx http://localhost/repo/
 