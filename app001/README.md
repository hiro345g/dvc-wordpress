# app001

## 概要

`app001` は、WordPress 環境内に独立した PHP アプリケーションを共存させる方法を示すサンプルプロジェクトです。

このアプリケーションは、PHP ページ (`index.php`) と静的コンテンツ (`/static`) で構成されています。URL のパスが `/app001/user/` のように深くなっても CSS や画像などのパスが崩れないよう、`config.php` で基準となる URL を動的に解決する仕組みを取り入れています。

また、`app001` ディレクトリ全体が BASIC 認証で保護されるように設定されています。

## .htaccess ファイル

dvc-wordpress の環境では Apache + mod_rewrite を使ったルーティングを `.htaccess` で指定する前提です。

自作する PHP アプリや実行環境によって、`.htaccess` ファイルの内容は調整が必要です。

ここで用意してある `app001/.htaccess` では次の内容を含んだものとしてあります。これで、`app001/` のパスへのアクセスについては、パスと対応するファイルやフォルダが存在しない場合に `app001/index.php` へのアクセスになります。

```htaccess
AuthType Basic
AuthName "Restricted Area"
AuthUserFile /home/node/workspace/php/.htpasswd
Require valid-user

<IfModule mod_rewrite.c>
    RewriteEngine On

    # 物理的なファイルやディレクトリが存在しない場合のみ実行
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d

    # フォルダ名を書かずに、現在の階層の index.php へ飛ばす
    # (先頭にスラッシュをつけないのがポイント)
    # RewriteRule ^(.*)$ index.php [L]
    RewriteRule . index.php [L]
</IfModule>
```

`webroot/.htaccess` では次の内容を含んだものを用意してあります。これで、`app001/` のパスへのアクセスは `app001/` へのアクセスになります。ここに、WordPress のルーティングのための設定が必要な場合に追加されますが、WordPress の設定より先に、この設定を指定すれば、自作の PHP アプリを WordPress のフォルダ内に置いて、公開することができます。

```htaccess
<IfModule mod_rewrite.c>
# WordPress の設定により、自動で有効になったり無効になったりするので、明示的に最初に指定が必要。
# 複数回指定しても問題ない。
RewriteEngine On

RewriteRule ^app001/ - [L]
</IfModule>
```

## 提供するパス

| パス         | 説明                                                                       |
| ------------ | -------------------------------------------------------------------------- |
| `index.php`  | アプリケーションのメインとなるエントリポイント                             |
| `config.php` | アプリケーションのルートパスを動的に定義し、アセットへのリンクを正しく生成 |
| `static/`    | HTML, CSS などの静的ファイルを格納するディレクトリ                         |
| `info.php`   | PHP の環境情報を表示                                                       |

## dvc-wordpress での利用方法

`dvc-wordpress` 環境で `app001` を動作させるための手順は次のとおりです。

### 1. アプリケーションの配備

まず、`app001` の関連ファイルを `dvc-wordpress` の Web ルートにコピーします。

```bash
docker compose -p dvc-wordpress exec dvc-wordpress \
    cp -r /dvc-wordpress/app001/webroot/* \
        /dvc-wordpress/app001/webroot/.* \
        /dvc-wordpress/app001/resources/dev/info.php \
        /home/node/workspace/php/html/
```

ここでは、開発環境なので `info.php` をコピーしています。運用環境ではこのファイルを使わないこと。もし必要があって使う場合は外部からアクセスできないように設定してからデプロイすること。

### 2. BASIC認証の設定

次に、`app001` ディレクトリを保護するための BASIC 認証を設定します。
サンプル用の認証情報ファイル (`dot.htpasswd`) を適切な場所にコピーし、パーミッションを設定します。

- **ユーザー名**: `user001`
- **パスワード**: `pass001`

```bash
# 認証ファイルをコピー
docker compose -p dvc-wordpress exec dvc-wordpress \
    cp -r /dvc-wordpress/app001/resources/dot.htpasswd \
        /home/node/workspace/php/.htpasswd

# パーミッションを設定
docker compose -p dvc-wordpress exec dvc-wordpress \
    chmod 600 /home/node/workspace/php/.htpasswd
```

### 3. 動作確認

Web ブラウザでアクセスする以外に、`curl` コマンドでも動作確認ができます。

#### 認証成功

`--user` オプションでユーザー名とパスワードを指定すると、ページの HTML が返されます。

```bash
curl --user user001:pass001 -s http://localhost:8080/app001/ | grep '<title>App001'
```

**実行結果例:**

```html
<title>App001 - PHP Application</title>
```

#### 認証失敗

認証情報を指定しない、または間違った情報を指定した場合、`401 Authorization Required` が返されます。

```bash
curl -s -I http://localhost:8080/app001/ | grep "HTTP/1.1"
```

**実行結果例:**

```text
HTTP/1.1 401 Unauthorized
```

## PHP の情報

現在使用している PHP の情報は、Web のドキュメントルートに用意した `info.php` で確認できます。

| URL                              | 説明                                  |
| -------------------------------- | ------------------------------------- |
| <http://localhost:8080/info.php> | 現在使用している PHP 環境の情報を表示 |

## 認証用ファイルの更新

認証情報は `php-apache` コンテナに用意されている `htpasswd` コマンドで作成・更新できます。
`USER_NAME` や `PASSWORD` の値を変更してコマンドを実行してください。

### 新規作成

```bash
USER_NAME=user001
PASSWORD=pass002
docker compose -p dvc-wordpress exec php-apache \
    htpasswd -cb /home/node/workspace/php/.htpasswd ${USER_NAME} ${PASSWORD}
```

### 更新

```bash
USER_NAME=user001
PASSWORD=pass002
docker compose -p dvc-wordpress exec php-apache \
    htpasswd -b /home/node/workspace/php/.htpasswd ${USER_NAME} ${PASSWORD}
```

### 内容確認

```bash
docker compose -p dvc-wordpress exec php-apache \
    cat /home/node/workspace/php/.htpasswd
```

**実行例:**

```bash
$ USER_NAME=user001
$ PASSWORD=pass001
$ docker compose -p dvc-wordpress exec php-apache \
    htpasswd -cb /home/node/workspace/php/.htpasswd ${USER_NAME} ${PASSWORD}
Adding password for user user001
$ docker compose -p dvc-wordpress exec php-apache \
    cat /home/node/workspace/php/.htpasswd
user001:$apr1$GS1.CvTA$alJI/WirTun9ZxirkAoFN1
$ USER_NAME=user001
$ PASSWORD=pass002
$ docker compose -p dvc-wordpress exec php-apache \
    htpasswd -b /home/node/workspace/php/.htpasswd ${USER_NAME} ${PASSWORD}
Updating password for user user001
```

## セキュリティ上の注意事項

WordPress のような既存のアプリケーション内に自作の PHP アプリを組み込む際には、セキュリティに特に注意を払う必要があります。

- **入力値の検証とサニタイズ**: ユーザーからの入力 (`$_GET`, `$_POST` など) は常に信頼せず、必ず検証とサニタイズを行ってください。SQL インジェクションやクロスサイトスクリプティング (XSS) などの脆弱性を防ぐための基本です。

- **出力時のエスケープ**: ユーザーが入力したデータを画面に出力する際は、`htmlspecialchars()` 関数などを用いて必ずエスケープ処理を行ってください。これにより、意図しない HTML タグやスクリプトが実行されるのを防ぎます。

- **エラー報告**: 本番環境では、`display_errors` を `Off` に設定し、詳細なエラーメッセージがエンドユーザーに表示されないようにしてください。エラーメッセージは、攻撃者にシステムの内部構造に関するヒントを与えてしまう可能性があります。エラーはファイルに記録することを推奨します。

- **最小権限の原則**: ファイルやディレクトリのパーミッションは、必要最小限に設定してください。特に、アップロードされたファイルを保存するディレクトリに実行権限を与えない、設定ファイルを Web から直接アクセスできない場所に置くなどの対策が重要です。
