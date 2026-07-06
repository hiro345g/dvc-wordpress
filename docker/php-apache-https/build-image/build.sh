#!/bin/sh
SCRIPT_DIR=$(dirname "$0")

if docker image ls --format "{{.Repository}}:{{.Tag}}" | grep "dvc-wordpress:php-apache" > /dev/null; then
  :
else
  if [ ! -e "${SCRIPT_DIR}/../../php-apache/build-image/build.sh" ]; then
    echo "Please build dvc-wordpress:php-apache image"
    exit 1
  fi
  echo "---- building dvc-wordpress:php-apache image"
  # shellcheck disable=SC2068
  bash "${SCRIPT_DIR}/../../php-apache/build-image/build.sh" $@
fi

# shellcheck disable=SC2068
docker compose -f "${SCRIPT_DIR}/compose.yaml" build $@
