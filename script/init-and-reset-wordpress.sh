#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
PROJECT_DIR=$(cd "${SCRIPT_DIR}/.." || exit 1;pwd)

# dvc-wordpress 環境クリア
bash "${PROJECT_DIR}/script/clean.sh"

# dvc-wordpress 環境の用意
bash "${PROJECT_DIR}/script/init.sh"

# dvc-wordpress 用コンテナの起動
docker compose -f "${PROJECT_DIR}/compose.yaml" up -d

# /home/node/workspace/php/html/init-wp.sh の用意
docker compose -p dvc-wordpress exec php-apache bash -c "
  cp /var/www/html/init-wp.sh /home/node/workspace/php/html/ 
"

# デバッガ用設定の無効化
docker compose -p dvc-wordpress exec -u 0:0 php-apache \
  mv /usr/local/etc/php/conf.d/xdebug.ini \
    /usr/local/etc/php/conf.d/xdebug.ini.disabled
docker compose -p dvc-wordpress exec -u 0:0 php-apache kill -HUP 1

# WordPress ブログを自動作成
docker compose -p dvc-wordpress exec php-apache bash -c '
  cd /home/node/workspace/php/html/ && WEB_ROOT_DIR=$(pwd) bash init-wp.sh
'

# dvc-wordpress 用コンテナの破棄
docker compose -p dvc-wordpress down
