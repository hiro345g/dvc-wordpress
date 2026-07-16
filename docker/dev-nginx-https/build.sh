#!/bin/sh
SCRIPT_DIRNAME=$(dirname "$0")
SCRIPT_DIR=$(cd "${SCRIPT_DIRNAME}" || exit 1; pwd)
DC_PROJECT_DIR="${SCRIPT_DIR}"
DC_PROJECT=$(basename "${DC_PROJECT_DIR}")
PROJECT_DOCKER_DIR=$(cd "${DC_PROJECT_DIR}"/.. || exit 1; pwd)

if [ "${SITE_HOSTNAME}" = "" ]; then
  SITE_HOSTNAME=www.dev.internal
fi

echo "Docker Compose Project: ${DC_PROJECT}"

if [ ! -e "${PROJECT_DOCKER_DIR}/mkcert/backup/mkcert-keys/certs/${SITE_HOSTNAME}.pem" ]; then
  echo "${PROJECT_DOCKER_DIR}/mkcert/backup/mkcert-keys/certs/${SITE_HOSTNAME}.pem not found"
  exit 1;
fi
if [ ! -e "${PROJECT_DOCKER_DIR}/mkcert/backup/mkcert-keys/private/${SITE_HOSTNAME}.key" ]; then
  echo "${PROJECT_DOCKER_DIR}/mkcert/backup/mkcert-keys/private/${SITE_HOSTNAME}.key not found"
  exit 1;
fi

if docker image ls --format "{{.Repository}}:{{.Tag}}" | grep "dvc-wordpress:${DC_PROJECT}" > /dev/null; then
  echo "rebuild..."
else
  echo "build..."
fi

# shellcheck disable=SC2068
docker compose -f "${SCRIPT_DIR}/compose.yaml" build $@
