#!/bin/sh
DC_PROJ_NAME=dvc-wordpress

docker compose -p ${DC_PROJ_NAME} start php-apache-db
docker compose -p ${DC_PROJ_NAME} start php-apache-adminer
docker compose -p ${DC_PROJ_NAME} start php-apache
docker compose -p ${DC_PROJ_NAME} start php-apache-nginx-proxy
docker compose -p ${DC_PROJ_NAME} start nginx-proxy
