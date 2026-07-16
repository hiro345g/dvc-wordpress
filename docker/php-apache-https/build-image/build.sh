#!/bin/sh
SCRIPT_DIRNAME=$(dirname "$0")
SCRIPT_DIR=$(cd "${SCRIPT_DIRNAME}" || exit 1; pwd)
DC_PROJECT_DIR=$(cd "${SCRIPT_DIR}"/.. || exit 1; pwd)
DC_PROJECT=$(basename "${DC_PROJECT_DIR}")
PROJECT_DOCKER_DIR=$(cd "${DC_PROJECT_DIR}"/.. || exit 1; pwd)

echo "Docker Compose Project: ${DC_PROJECT}"

if docker image ls --format "{{.Repository}}:{{.Tag}}" | grep "dvc-wordpress:php-apache" > /dev/null; then
  :
else
  if [ ! -e "${PROJECT_DOCKER_DIR}/php-apache/build-image/build.sh" ]; then
    echo "Please build dvc-wordpress:php-apache image"
    exit 1
  fi
  echo "---- building dvc-wordpress:php-apache image"
  # shellcheck disable=SC2068
  bash "${PROJECT_DOCKER_DIR}/php-apache/build-image/build.sh" $@
fi

# shellcheck disable=SC2068
docker compose -f "${SCRIPT_DIR}/compose.yaml" build $@
