#!/bin/sh
DC_PROJ_NAME=dvc-wordpress

docker compose -p ${DC_PROJ_NAME} start php-apache-mysql
docker compose -p ${DC_PROJ_NAME} start php-apache-adminer
docker compose -p ${DC_PROJ_NAME} start php-apache
