# php-apache-https

`../mkcert/README.md` に従って証明書用ファイルを作成し、`../mkcert/backup` にバックアップしてから `dvc-wordperss:php-apache-https` イメージをビルドすること

ホスト名を例えば `www.example.jp` に変えたい場合は設定ファイルを変更。

```bash
sed -i 's/www.dev.internal/www.example.jp/' ./build-image/etc/apache2/sites-available/001-ssl.conf
sed -i 's/www.dev.internal/www.example.jp/' ./compose.yaml
```

鍵ファイルのコピー

```bash
cp ../mkcert/backup/mkcert-keys/certs/www.dev.internal.pem ./build-image/etc/ssl/certs/site.pem
cp ../mkcert/backup/mkcert-keys/private/www.dev.internal.key ./build-image/etc/ssl/private/site.key
```

イメージビルドの準備ができたら、ビルド。

```bash
bash ./build-image/build.sh
```
