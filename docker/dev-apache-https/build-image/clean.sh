#!/bin/sh
SCRIPT_DIRNAME=$(dirname "$0")
SCRIPT_DIR=$(cd "${SCRIPT_DIRNAME}" || exit 1; pwd)

if [ -e "${SCRIPT_DIR}/conf/httpd-ssl.conf" ]; then
  rm "${SCRIPT_DIR}/conf/httpd-ssl.conf"
fi
if [ -e "${SCRIPT_DIR}/conf/certs/server.crt" ]; then
  rm "${SCRIPT_DIR}/conf/certs/server.crt"
fi
if [ -e "${SCRIPT_DIR}/conf/certs/server.key" ]; then
  rm "${SCRIPT_DIR}/conf/certs/server.key"
fi
