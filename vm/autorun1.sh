#!/bin/bash
# Записываем hosts (по-хорошему тоже в vagrant-файле следовало бы это как-то реализовать, но лень думать над этим пока что)
echo "192.168.120.61    ubuntu-sdb-homework-12-06-vm1" >> /etc/hosts
echo "192.168.120.62    ubuntu-sdb-homework-12-06-vm2" >> /etc/hosts

# ставим mysql
apt-get update && apt-get install -y mysql-server mysql-client

# Создаем пользователя в MySQL
mysql < /vagrant/inner_mysql1.sql
# подкидываем конфиг MySQL
cp -f /vagrant/mysql1.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql

# получаем позицию SHOW MASTER STATUS;
mysql -e "show master status\G" | grep "Position"| cut -d ":" -f2 | xargs > /vagrant/master_status_position
chmod 755 /vagrant/master_status_position
mysql -e "show master status\G" | grep "File"| cut -d ":" -f2 | xargs > /vagrant/master_status_file
chmod 755 /vagrant/master_status_file
