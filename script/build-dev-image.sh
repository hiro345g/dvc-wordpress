#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
BASE_DIR=$(cd "${SCRIPT_DIR}/.." || exit 1;pwd)

bash "${BASE_DIR}/docker/dev-apache-https/build-image/build.sh"
docker compose -f "${BASE_DIR}/docker/dev-caddy/compose.yaml" build
bash "${BASE_DIR}/docker/dev-frankenphp-wp/build-image/build.sh"
bash "${BASE_DIR}/docker/dev-nginx-https/build.sh"
bash "${BASE_DIR}/docker/dev-php-apache-wp/build.sh"
bash "${BASE_DIR}/docker/dev-php-fpm-wp/build-image/build.sh"
bash "${BASE_DIR}/docker/dev-wp-fpm/build.sh"
bash "${BASE_DIR}/docker/mkcert/build-image/build.sh"
bash "${BASE_DIR}/docker/php-apache/build-image/build.sh"
bash "${BASE_DIR}/docker/php-apache-https/build-image/build.sh"
