#!/bin/sh
SCRIPT_DIRNAME=$(dirname "$0")
SCRIPT_DIR=$(cd "${SCRIPT_DIRNAME}" || exit 1; pwd)
DC_PROJECT_DIR="${SCRIPT_DIR}"
DC_PROJECT=$(basename "${DC_PROJECT_DIR}")

echo "Docker Compose Project: ${DC_PROJECT}"

if docker image ls --format "{{.Repository}}:{{.Tag}}" | grep "dvc-wordpress:${DC_PROJECT}" > /dev/null; then
  echo "rebuild..."
else
  echo "build..."
fi

# shellcheck disable=SC2068
docker compose -f "${SCRIPT_DIR}/compose.yaml" build $@
