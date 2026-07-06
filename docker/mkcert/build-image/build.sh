#!/bin/sh
SCRIPT_DIRNAME=$(dirname "$0")
SCRIPT_DIR=$(cd "${SCRIPT_DIRNAME}" || exit 1; pwd)

# shellcheck disable=SC2068
docker compose -f "${SCRIPT_DIR}/compose.yaml" build $@
