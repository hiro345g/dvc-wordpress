#!/bin/sh
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC2068
docker compose -f "${SCRIPT_DIR}/compose.yaml" build $@
