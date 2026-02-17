#! /bin/bash

PLUGINS="${PLUGIN_LIST:-all-in-one-wp-migration backwpup query-monitor}"
WP_RESET="${RESET:-TRUE}"

echo "Setting up WordPress"
SCRIPT_DIRNAME=$(dirname "$0")
SCRIPT_DIR=$(cd "${SCRIPT_DIRNAME}" || exit 1; pwd)
DATA_DIR="${SCRIPT_DIR}/data"
WORK_DIR=${WEB_ROOT_DIR:-/var/www/html}

cd "${WORK_DIR}" || exit 1;

# WordPress のダウンロード
wp core download --locale=ja

# 設定のリセット
if [ "${WP_RESET}" = "TRUE" ]; then
    echo "---- reset"
    # shellcheck disable=SC2086
    if [ -e "${WORK_DIR}/wp-config.php" ]; then
        for p in $PLUGINS; do
            if [ -e "${WORK_DIR}/wp-content/plugins/${p}" ]; then
                wp plugin delete "${p}"
            fi
        done
        wp db reset --yes
        rm wp-config.php;
    fi
fi

# 初期設定
if [ -f wp-config.php ]; then
    echo "---- already configured"
else
    echo "---- configuring..."
    wp config create \
        --dbhost="${DB_HOST:-php-apache-mysql}" \
        --dbname="${DB_NAME:-wordpress}" \
        --dbuser="${DB_USER:-dbuser001}" \
        --dbpass="${DB_PASS:-dbpass001}" \
        --skip-check;
    wp core install \
        --url="http://localhost:8080" \
        --title="${SITE_TITLE:-DevSite}" \
        --admin_user="${ADMIN_USER:-user001}" \
        --admin_password="${ADMIN_PASS:-pass001}" \
        --admin_email="${ADMIN_EMAIL:-user001@dev.internal}" \
        --skip-email;
    # shellcheck disable=SC2086
    wp plugin install $PLUGINS --activate

    # SQL データのインポート
    if [ -e "${DATA_DIR}/" ]; then
        cd "${DATA_DIR}/" || exit 1
        for f in *.sql; do
            wp db import "${f}"
        done
    else
        echo "not exist ${DATA_DIR}/, skip import"
    fi
fi
