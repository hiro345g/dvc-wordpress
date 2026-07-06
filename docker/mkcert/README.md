# dvc-wordpress-mkcert

dvc-wordpress-mkcert は開発用サーバ証明書を用意する環境を提供します。

## イメージビルド

```bash
docker compose -f ./build-image/compose.yaml build
```

## 初期設定

CA 初期化、サンプルとして `www.dev.internal` 用証明書作成

```bash
docker compose run --rm -it mkcert sh /script/gen.sh
```

## 起動

コンテナ起動

```bash
docker compose up -d
```

## 利用

新しい証明書作成

```bash
server=mailpit.dev.internal
if docker container ls | grep dvc-wordpress-mkcert > /dev/null 2> /dev/null; then
    docker compose -p dvc-wordpress-mkcert exec mkcert sh /script/gen.sh ${server}
else
    docker compose run --rm -it mkcert sh /script/gen.sh ${server}
fi
```

`dev-*.dev.internal` 用に `script/gen_dev.sh` を用意してあるので、これらの証明書を作成したい場合は次のように実行。

```bash
bash script/gen_dev.sh
```

## バックアップ

```bash
docker compose -p dvc-wordpress-mkcert cp mkcert:/mkcert-keys ./backup/
docker compose -p dvc-wordpress-mkcert cp mkcert:/root/.local/share/mkcert ./backup/
```

## 停止

```bash
docker compose -p dvc-wordpress-mkcert down
```

## 秘密鍵と証明書の確認

秘密鍵の確認については、次のコマンドを実行してエラーが起きなければ良い。

```bash
openssl rsa -in ./backup/mkcert/rootCA-key.pem -text -noout
openssl rsa -in ./backup/mkcert-keys/private/www.dev.internal.key -text -noout
```

X.509 形式の公開鍵証明書が正しく作成されているかについては、次のコマンドを実行して出力されるテキストで確認できる。

```bash
openssl x509 -in ./backup/mkcert/rootCA.pem -text -noout
openssl x509 -in ./backup/mkcert-keys/certs/www.dev.internal.pem -text -noout
```
