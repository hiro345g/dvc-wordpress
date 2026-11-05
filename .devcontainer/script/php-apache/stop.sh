#!/bin/sh
DC_PROJ_NAME=dvc-wordpress

docker compose -p ${DC_PROJ_NAME} stop nginx-proxy
docker compose -p ${DC_PROJ_NAME} stop php-apache-nginx-proxy
docker compose -p ${DC_PROJ_NAME} stop php-apache
docker compose -p ${DC_PROJ_NAME} stop php-apache-adminer
docker compose -p ${DC_PROJ_NAME} stop php-apache-db
