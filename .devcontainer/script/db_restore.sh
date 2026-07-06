#!/bin/sh
# WordPress の DB リストア
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
docker compose -p "${DC_PROJECT}" cp "${FILENAME}" "${DB_HOST}":/var/lib/mysql/
docker compose -p "${DC_PROJECT}" exec "${DB_HOST}" sh -c "\
if mariadb --version > /dev/null 2> /dev/null; then
    mariadb -u ${DB_USER} -p ${DB_NAME} < \"/var/lib/mysql/${FILENAME}\";
else
    mysql -u ${DB_USER} -p ${DB_NAME} < \"/var/lib/mysql/${FILENAME}\";
fi \
"

# --- リストア
# mariadb -u "${DB_USER}" -p "${DB_NAME}" < "${FILENAME}"
# --- MariaDB に ${DB_NAME} のデータベースがなく、作成が必要な場合は次のコマンドで作成
# mariadb -u "${DB_USER}" -p -e "CREATE DATABASE "${DB_NAME}";"
