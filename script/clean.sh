#!/bin/bash

list=$(cat << EOS
dvc-wordpress-home-node-workspace-data
dvc-wordpress-node-local-share-mise
dvc-wordpress-node-local-state-mise
dvc-wordpress-php-apache-data
dvc-wordpress-php-apache-mysql-data
dvc-wordpress-vscode-server-extensions
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
echo "docker image rm dvc-wordpress:php-202602"
echo "docker image rm dvc-wordpress:php-apache"
