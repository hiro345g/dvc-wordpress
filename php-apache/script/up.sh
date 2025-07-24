#!/bin/sh
SCRIPT_DIR=$(dirname "$0")
PHP_APACHE_DIR=$(cd "${SCRIPT_DIR}/.." || exit 1;pwd)

# Docker ボリュームの確認
if docker volume ls | grep dvc-node-workspace-data > /dev/null; then
    :
else
    DVC_DC_DIR=$(cd "${PHP_APACHE_DIR}/../" || exit 1;pwd)
    docker compose -f "${DVC_DC_DIR}/compose.yaml" up -d
    until \
        docker compose ls | grep "dvc-wordpress" | grep "running"
    do
        >&2 echo "dvc-wordpress is not available - sleeping"
        sleep 1
    done
    docker compose -f "${DVC_DC_DIR}/compose.yaml" down
fi

# Docker ネットワークの確認
if docker network ls | grep dvc-wordpress-net > /dev/null; then
    :
else
    docker network create dvc-wordpress-net
fi

# 起動
docker compose -f "${PHP_APACHE_DIR}/compose.yaml" up -d
