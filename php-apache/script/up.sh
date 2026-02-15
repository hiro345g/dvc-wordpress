#!/bin/sh
SCRIPT_DIR=$(dirname "$0")
PHP_APACHE_DIR=$(cd "${SCRIPT_DIR}/.." || exit 1;pwd)

# dvc-wordpress 用 Docker ボリュームの確認
if docker volume ls | grep dvc-wordpress-home-node-workspace-data > /dev/null; then
    :
else
    DVC_DC_DIR=$(cd "${PHP_APACHE_DIR}/../" || exit 1;pwd)
    docker compose -f "${DVC_DC_DIR}/compose.yaml" up dvc-wordpress -d
    until \
        docker compose ls | grep "dvc-wordpress" | grep "running"
    do
        >&2 echo "dvc-wordpress is not available - sleeping"
        sleep 10
    done
    docker compose -f "${DVC_DC_DIR}/compose.yaml" down
fi

# php-apache-core 用 Docker ボリュームの確認
if docker volume ls | grep dvc-wordpress-php-apache-data > /dev/null; then
    :
else
    DVC_DC_DIR=$(cd "${PHP_APACHE_DIR}/php-apache-core/" || exit 1;pwd)
    docker compose -f "${DVC_DC_DIR}/compose.yaml" up -d
    docker compose -f "${DVC_DC_DIR}/compose.yaml" down
fi

# Docker ネットワークの確認
# - dvc-wordpress-net があったら external: true、なければ external: false
DC_OPT="-f ${PHP_APACHE_DIR}/compose.yaml"
if docker network ls | grep dvc-wordpress-net > /dev/null; then
    :
else
    DC_OPT="${DC_OPT} -f ${PHP_APACHE_DIR}/compose-net.yaml"
fi

# 起動
# shellcheck disable=SC2086
docker compose ${DC_OPT} up -d
