#!/bin/sh
DC_PROJ_NAME=php-apache

docker compose -p ${DC_PROJ_NAME} down

if docker compose ls | grep "dvc-wordpress" | grep "running" > /dev/null; then
    # 開発コンテナが起動している場合は dvc-wordpress-net ネットワークはそのまま
    :
else
    # dvc-wordpress-net ネットワークは自動で削除されるはずだが、もし存在していたら削除
    if docker network ls | grep "dvc-wordpress-net" > /dev/null; then
        docker network rm dvc-wordpress-net
    fi
fi
