# При выполнение ДЗ использовалось следуещие окружение: 
    ОС Ubuntu Desctop 22.04
    VirtualBox 6.1.38
    Vagrant 2.3.3
    Плагин vagrant-vbguest 0.21
# ДЗ* Процес автоматизирован: 
  Установка пакетов для выполнения дз
  Конфигурация сервисов
# Скрипт автонастройки:
  Скрипты находится в директории /project/work_8/scripts/
# Для запуска проекта и проверки выполнения дз  необходимо выполнить следующие команды:
# Клонируем репозиторий
 git clone https://github.com/chelenjer27/project 
# Переходим в рабочий каталог проекта
 cd /project/work_8
# Запускаем виртуальную машину
vagrant up
# Подключаемся к виртуальной машине сервер
vagrant ssh 
# Проверяем  работу unit сервисов
sudo systemctl status  httpd@first httpd@second watchlog.timer
# Отпровляем сообщение ALERT
logger ALLERT
# Проверяем сообщение в журнале I found word, Master!
sudo tail -f /var/log/messages
# Проверяем порты httpd
ss -tunlp | grep httpd


