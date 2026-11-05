#!/bin/sh
#
# 単純に存在しているファイルのみバックアップ
#

BACKUP_DIR=/workspace/dvc-wordpress-mkcert

# BACKUP_DIR がない場合は作成
if [ ! -e ${BACKUP_DIR} ]; then
    mkdir -p ${BACKUP_DIR}
fi

# 現在のものはすべて削除
for d in dvc-wordpress-mkcert-data ca docker; do
    if [ -e ${BACKUP_DIR}/${d} ]; then
        rm -fr "${BACKUP_DIR:?}/${d:?}"
    fi
done

# バックアップ
cp -r /dvc-wordpress-mkcert-data ${BACKUP_DIR}/
cp -r /dvc-wordpress-mkcert-root/.local/share/mkcert ${BACKUP_DIR}/ca 
cp -r /docker ${BACKUP_DIR}/

# ca/rootCA.pem と同じファイルなので下記ファイルは削除
if [ -e ${BACKUP_DIR}/dvc-wordpress-mkcert-data/certs/rootCA.pem ]; then
    rm ${BACKUP_DIR:?}/dvc-wordpress-mkcert-data/certs/rootCA.pem
fi
