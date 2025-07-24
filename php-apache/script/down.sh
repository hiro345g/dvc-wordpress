#!/bin/sh
DC_PROJ_NAME=php-apache

docker compose -p ${DC_PROJ_NAME} down

# 開発コンテナが起動していない場合は dvc-wordpress-net ネットワークは削除
if docker compose ls | grep "dvc-wordpress" | grep "running" > /dev/null; then
    :
else
    docker network rm dvc-wordpress-net
fi
