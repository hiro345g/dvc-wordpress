# バックアップ用コンテナ

Docker ボリューム `dvc-wordpress-mkcert-util-data` へ、証明書ファイルをバックアップするための `compose.yaml` ファイルです。

次のように実行することで `${REPO_DIR}/mkcert/backup/dvc-wordpress-mkcert-data` に証明書ファイルをバックアップします。

```bash
BACKUP_PATH=${REPO_DIR}/mkcert/backup
docker compose up -d
docker compose -p dvc-wordpress-mkcert-util exec dvc-wordpress-mkcert-util \
  bash /script/backup.sh
docker compose -p dvc-wordpress-mkcert-util \
  cp dvc-wordpress-mkcert-util:/dvc-wordpress-mkcert-data ${BACKUP_PATH}
docker compose -p dvc-wordpress-mkcert-util down
```
