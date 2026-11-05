#!/bin/sh
# WordPress の DB バックアップ
# CONFIG_FILE=/var/www/html/wp-config.php
CONFIG_FILE=/home/node/workspace/php/html/wp-config.php
DC_PROJECT=dvc-wordpress
DB_HOST=$(sudo cat ${CONFIG_FILE} |grep DB_HOST | awk '{print $3}' | sed "s/'//g" )
DB_NAME=$(sudo cat ${CONFIG_FILE} |grep DB_NAME| awk '{print $3}' | sed "s/'//g" )
DB_USER=$(sudo cat ${CONFIG_FILE} |grep DB_USER| awk '{print $3}' | sed "s/'//g" )
DB_PASSWORD=$(sudo cat ${CONFIG_FILE} |grep DB_PASSWORD | awk '{print $3}' | sed "s/'//g" )
#FILENAME="${DB_NAME}.$(date '+%Y%m%d%H%M%S')".sql
FILENAME="${DB_NAME}.$(date '+%Y%m%d')".sql

# コンソールへパスワードを表示
echo "DB_PASSWORD: $DB_PASSWORD"
# パスワード入力画面が表示されるので表示されたパスワードをコピー＆ペーストで入力
if docker compose -p "${DC_PROJECT}" exec "${DB_HOST}" sh -c "mariadb --version > /dev/null 2> /dev/null"; then
    docker compose -p "${DC_PROJECT}" exec "${DB_HOST}" sh -c "\
        mariadb-dump -u ${DB_USER} -p ${DB_NAME} \
    " > "${FILENAME}";
else
    docker compose -p "${DC_PROJECT}" exec "${DB_HOST}" sh -c "\
        mysqldump -u ${DB_USER} -p ${DB_NAME} \
    " > "${FILENAME}"
fi

# --- バックアップ
# mariadb-dump -u "${DB_USER}" -p "${DB_NAME}" > "${DB_NAME}.$(date '+%Y%m%d')".sql
