#!/bin/sh

# SERVER_NAME へサーバ名を指定。
# パラメーターで指定されていたら、それを使用
if [ $# -gt 0 ]; then
    SERVER_NAME=$1
else
    # 環境変数で指定されていたら、それをそのまま使用
    if [ "${SERVER_NAME}" = "" ]; then
        # 環境変数で指定されていないならデフォルト値を指定
        SERVER_NAME=www.dev.internal
    fi
fi

# 鍵を生成する先のディレクトリーの存在チェックと作成
if [ ! -e /mkcert-keys/private ]; then
    mkdir -p /mkcert-keys/private
fi
if [ ! -e /mkcert-keys/certs ]; then
    mkdir -p /mkcert-keys/certs
fi
# CA の公開鍵について登録がない場合は対応
CA_CERT_DIR=/usr/local/share/ca-certificates
PRE_CA_CERT_FILE=${CA_CERT_DIR}/mkcert_development_CA
NUMBER_OF_FILE=$(find ${PRE_CA_CERT_FILE}* -type f | wc -l) \
    >/dev/null 2>&1
if [ "${NUMBER_OF_FILE}" -eq 0 ]; then
    /usr/local/bin/mkcert -install
fi

# CA の公開鍵について /mkcert-keys/certs にない場合は対応
if [ ! -e /mkcert-keys/certs/rootCA.pem ]; then
    cp /root/.local/share/mkcert/rootCA.pem /mkcert-keys/certs
fi

# サーバ証明書の作成
/usr/local/bin/mkcert \
    -key-file "/mkcert-keys/private/${SERVER_NAME}.key" \
    -cert-file "/mkcert-keys/certs/${SERVER_NAME}.pem" \
    localhost 127.0.0.1 "${SERVER_NAME}"
