#!/bin/sh
#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
BASE_DIR=$(cd "${SCRIPT_DIR}/.." || exit 1;pwd)
DC_FILE=${BASE_DIR}/compose.yaml

server_list=$(cat << EOS
mailpit.dev.internal
adminer.dev.internal
www.dev.internal
EOS
)
for server in ${server_list}; do
    if docker container ls | grep dvc-wordpress-mkcert > /dev/null 2> /dev/null; then
        docker compose -p dvc-wordpress-mkcert exec mkcert sh /script/gen.sh "${server}"
        docker compose -p dvc-wordpress-mkcert exec mkcert sh /script/gen.sh "dev-${server}"
    else
        docker compose -f "${DC_FILE}" run --rm -it mkcert sh /script/gen.sh "${server}"
        docker compose -f "${DC_FILE}" run --rm -it mkcert sh /script/gen.sh "dev-${server}"
    fi
done
