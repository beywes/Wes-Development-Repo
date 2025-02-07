#!/bin/bash

# Wait for MySQL to be ready
while ! nc -z ${db_host} 3306; do
  sleep 1
done

# Configure WordPress to use external database
sudo /opt/bitnami/wordpress/wp-config.php << EOF
<?php
define('DB_NAME', '${db_name}');
define('DB_USER', '${db_user}');
define('DB_PASSWORD', '${db_password}');
define('DB_HOST', '${db_host}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

\$table_prefix = 'wp_';

define('WP_DEBUG', false);

if ( ! defined('ABSPATH') ) {
    define('ABSPATH', dirname(__FILE__) . '/');
}

require_once ABSPATH . 'wp-settings.php';
EOF

# Restart Apache
sudo /opt/bitnami/ctlscript.sh restart apache
