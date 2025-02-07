#!/bin/bash

# Configure MySQL
sudo /opt/bitnami/mysql/bin/mysql -u root << EOF
CREATE DATABASE ${db_name};
CREATE USER '${db_user}'@'%' IDENTIFIED BY '${db_password}';
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'%';
FLUSH PRIVILEGES;
EOF

# Configure MySQL to allow remote connections
sudo sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /opt/bitnami/mysql/conf/my.cnf

# Restart MySQL
sudo /opt/bitnami/ctlscript.sh restart mysql
