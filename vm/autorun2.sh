#!/bin/bash

# Ждём файл с позицией /vagrant/master_status_position
while [ ! -f /vagrant/master_status_position ] 
do
    echo "file master_status_position - waiting..."
    sleep 3
done
echo "!!! ФАЙЛ master_status_position ГОТОВ !!!"

# Ждём файл с позицией /vagrant/master_status_file
while [ ! -f /vagrant/master_status_file ] 
do
    echo "file master_status_file - waiting..."
    sleep 3
done
echo "!!! ФАЙЛ master_status_file ГОТОВ !!!"

# Записываем hosts (по-хорошему тоже в vagrant-файле следовало бы это как-то реализовать, но лень думать над этим пока что)
echo "192.168.120.61    ubuntu-sdb-homework-12-06-vm1" >> /etc/hosts
echo "192.168.120.62    ubuntu-sdb-homework-12-06-vm2" >> /etc/hosts

# ставим mysql
apt-get update && apt-get install -y mysql-server mysql-client

# подкидываем конфиг MySQL
cp -f /vagrant/mysql2.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql


# Донастраиваем MySQL
POSITION=$(cat /vagrant/master_status_position)
MASTER_LOG_FILE=$(cat /vagrant/master_status_file)
echo "CHANGE MASTER TO MASTER_HOST='ubuntu-sdb-homework-12-06-vm1', 
MASTER_USER='replication', MASTER_LOG_FILE='"$MASTER_LOG_FILE"', 
MASTER_LOG_POS="$POSITION";" > /vagrant/inner_mysql2.sql

# Создаем пользователя в MySQL
mysql < /vagrant/inner_mysql2.sql
mysql -e "START SLAVE;"
mysql -e "SHOW SLAVE STATUS\G"

#Удаляем файлы, чтобы при следующем развёртывании не было путаницы
rm -f /vagrant/master_status_position
rm -f /vagrant/master_status_file
