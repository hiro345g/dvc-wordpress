#!/bin/sh
SCRIPT_DIRNAME=$(dirname "$0")
SCRIPT_DIR=$(cd "${SCRIPT_DIRNAME}" || exit 1; pwd)
DC_PROJECT_DIR=$(cd "${SCRIPT_DIR}"/.. || exit 1; pwd)
DC_PROJECT=$(basename "${DC_PROJECT_DIR}")
PROJECT_DOCKER_DIR=$(cd "${DC_PROJECT_DIR}"/.. || exit 1; pwd)

if [ "${SITE_HOSTNAME}" = "" ]; then
  SITE_HOSTNAME=www.dev.internal
fi

echo "site: ${SITE_HOSTNAME}"
if [ "${SITE_HOSTNAME}" = "www.dev.internal" ]; then
  cp "${SCRIPT_DIR}/conf/httpd-ssl-www.dev.internal.conf" \
    "${SCRIPT_DIR}/conf/httpd-ssl.conf"
else
  sed "s/www\.dev\.internal/${SITE_HOSTNAME}/g" \
    "${SCRIPT_DIR}/conf/httpd-ssl-www.dev.internal.conf" \
    > "${SCRIPT_DIR}/conf/httpd-ssl.conf"
fi

echo "Docker Compose Project: ${DC_PROJECT}"

if [ ! -e "${SCRIPT_DIR}/conf/certs/server.crt" ]; then
  echo "${SCRIPT_DIR}/conf/certs/server.crt not found. copy"
  if [ -e "${PROJECT_DOCKER_DIR}/mkcert/backup/mkcert-keys/certs/${SITE_HOSTNAME}.pem" ]; then
    cp "${PROJECT_DOCKER_DIR}/mkcert/backup/mkcert-keys/certs/${SITE_HOSTNAME}.pem" "${SCRIPT_DIR}/conf/certs/server.crt"
  else
    echo "${PROJECT_DOCKER_DIR}/mkcert/backup/mkcert-keys/certs/${SITE_HOSTNAME}.pem not found"
  fi
fi
if [ ! -e "${SCRIPT_DIR}/conf/certs/server.key" ]; then
  echo "${SCRIPT_DIR}/conf/certs/server.key not found. copy"
  if [ -e "${PROJECT_DOCKER_DIR}/mkcert/backup/mkcert-keys/private/${SITE_HOSTNAME}.key" ]; then
    cp "${PROJECT_DOCKER_DIR}/mkcert/backup/mkcert-keys/private/${SITE_HOSTNAME}.key" "${SCRIPT_DIR}/conf/certs/server.key"
  else
    echo "${PROJECT_DOCKER_DIR}/mkcert/backup/mkcert-keys/private/${SITE_HOSTNAME}.key not found"
  fi
fi

if docker image ls --format "{{.Repository}}:{{.Tag}}" | grep "dvc-wordpress:${DC_PROJECT}" > /dev/null; then
  echo "rebuild..."
else
  echo "build..."
fi

# shellcheck disable=SC2068
docker compose -f "${SCRIPT_DIR}/compose.yaml" build $@
