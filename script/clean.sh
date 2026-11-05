#!/bin/bash

list=$(cat << EOS
dvc-wordpress-home-node-workspace-data
dvc-wordpress-node-local-share-mise
dvc-wordpress-node-local-state-mise
dvc-wordpress-php-apache-data
dvc-wordpress-php-apache-db-data
dvc-wordpress-vscode-server-extensions
EOS
)

list_image=$(cat <<EOS
dvc-wordpress:dev-frankenphp-wp-202611
dvc-wordpress:dev-php-apache-wp-202611
dvc-wordpress:dev-php-fpm-wp-202611
dvc-wordpress:dev-php-fpm-wp-nginx-202611
dvc-wordpress:dev-wp-fpm-nginx-202611
dvc-wordpress:mkcert-202611
dvc-wordpress:php-apache-https-202611
dvc-wordpress:php-apache-202611
dvc-wordpress:202611
EOS
)

for v in ${list}; do
    if docker volume ls | grep "${v}" > /dev/null; then
        docker volume rm "${v}"
    else
        echo "not exists: ${v}"
    fi
done

if docker network ls | grep dvc-wordpress-net > /dev/null; then
    docker network rm dvc-wordpress-net
else
    echo "not exists: dvc-wordpress-net"
fi

echo "---- Commands to remove Docker images ----"
for i in ${list_image}; do\
    if docker image ls | grep "${i}" > /dev/null; then
        docker image rm "${i}"
    else
        echo "not exists: ${i}"
    fi
done
