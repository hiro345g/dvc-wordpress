# WordPress 開発環境 (dvc-wordpress)

このプロジェクトは、`Docker` と `VS Code Dev Container` を利用して、WordPress の開発環境を構築・提供します。
dvc-wordpress プロジェクトは、使いやすい開発コンテナー dvc-wordpress、開発時に使いやすい WordPress 用コンテナー php-apache を提供するものです。高度な WordPress メインの Web サイトや Web サービスを構築するときにも使える開発環境を提供するためのものです。

開発者全員が `PHP`、`Apache`、`Xdebug` などを含む統一された実行環境を簡単に利用できるため、環境差異による問題を解消し、開発に集中できます。

## 1. 主な特徴

dvc-worpdress は、`Docker` と `Dev Container` により、OS に依存しない一貫した開発環境を提供します（統一された開発環境）。

また、`dvc-wordpress` 開発コンテナーを起動すると、WordPress が実行可能な Apache の Web サービスである `php-apache` と、関連するデータベースサービス（MySQL）が自動的に起動します。手動での `php-apache` サービスの起動が不要になり、統合されたワークフローで開発体験が向上します（WordPress 実行環境の自動連携）。

`Xdebug` も設定済みで、`VS Code` からすぐにステップ実行などのデバッグが可能です（デバッグ対応）。

セットアップについては、シェルスクリプトを実行するだけで、環境の構築から `WordPress` の初期設定までを自動化できます（簡単なセットアップ）。

`php-apache` コンテナー群は、`dvc-wordpress` 開発コンテナーと連携して利用するだけでなく、独立して運用することも可能です。これにより、リソースの最適化や柔軟な環境構築が実現できます（柔軟に利用可能なコンテナーの提供）。

`Dockerfile` や設定ファイルを変更することで、`PHP` のバージョンや `Apache` の設定を自由にカスタマイズできます（カスタマイズ可能）。

以上をまとめると、dvc-wordpress の主な特徴は次のようになります。

1. 統一された開発環境
2. WordPress 実行環境の自動連携
3. デバッグ対応
4. 簡単なセットアップ
5. 柔軟に利用可能なコンテナーの提供
6. カスタマイズ可能

## 2. 始め方

### 2.1. 前提条件

開発を始める前に、お使いの PC に以下のツールがインストールされている必要があります。

- [Node.js](https://nodejs.org/ja/) (開発コンテナー用 Docker イメージのビルドに `npm exec` コマンドを使用するため)
- `Docker`
  - [Docker Engine](https://docs.docker.com/engine/)
  - [Docker Compose](https://docs.docker.com/compose/)
- [Visual Studio Code](https://code.visualstudio.com/)

`Docker` については、[Docker Desktop](https://docs.docker.com/desktop/) でも良いです。`Docker Desktop` には `Docker Engine` と `Docker Compose` が含まれているからです。

また、次の `VS Code` 拡張機能もインストールしておいてください。

- [Container Tools](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-containers)
- [Docker DX](https://marketplace.com/items?itemName=docker.docker)
- [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### 2.2. 開発コンテナーの実行環境構築

以下の手順で開発コンテナーの実行環境を構築します。

1. リポジトリをクローン
2. 開発コンテナー用イメージ `dvc-wordpress:php-202602` のビルド
3. WordPress 用イメージ `dvc-wordpress:php-apache` のビルド
4. 使用する Docker オブジェクトの初期化

リポジトリから、dvc-wordpress フォルダを取得するには、次のようにします。

```bash
git clone https://github.com/hiro345g/dvc-wordpress.git
cd dvc-wordpress
```

ここでの作業は `dvc-wordpress` フォルダをカレントとしてコマンドを実行します。なお、これ以降、`dvc-wordperss` を `${PROJECT_DIR}` と表記します。

開発コンテナー用イメージ `dvc-wordpress:php-202602` のビルドをするには、`build-image/build.sh` を実行します。

```bash
bash ./build-image/build.sh
```

WordPress 用イメージ `dvc-wordpress:php-apache` のビルドをするには、`php-apache/build/build.sh` を実行します。

```bash
bash ./php-apache/build/build.sh
```

ビルドが成功したら、使用する Docker オブジェクトの初期化をします。

`php-apache/script/up.sh` を実行すると、自動で使用する Docker オブジェクトの初期化処理がされます。Docker オブジェクトがすでにある場合は初期化処理は無視されます。

```bash
bash ./php-apache/script/up.sh
```

これで `php-apache` 向けサービスが起動したら、使用する Docker オブジェクトの初期化は成功しています。

次のコマンドで `running` となっていることを確認します。

```bash
docker compose ls | grep php-apache
```

実行例は次のようになります。

```bash
$ docker compose ls | grep php-apache
php-apache          running(3)   （略）
```

確認ができたら、`php-apache/script/down.sh` を実行して php-apache プロジェクトで起動したコンテナーを破棄します。

```bash
bash ./php-apache/script/down.sh
```

### 2.3 開発コンテナーで WordPress を用意

開発コンテナーの実行環境が構築できたら、これを使って、開発対象となる WordPress を次の手順で用意します。

1. 開発コンテナー（`Dev Container`）の起動
2. php-apache（`WordPress` 実行環境）の起動確認
3. `WordPress` サイトの初期化設定

開発コンテナー（`Dev Container`）の起動をするには、`VS Code` でこのプロジェクトフォルダを開きます。VS Code を起動する `code` コマンドを使う場合は次を実行します。

```bash
cd ${PROJECT_DIR}
code .
```

VS Code でこのプロジェクトフォルダを開くと、通知が表示されるので、そこから「コンテナーで再度開く (Reopen in Container)」を選択するか、コマンドパレット (`Ctrl+Shift+P` または `Cmd+Shift+P`) から「開発コンテナー：コンテナーで再度開く (`Dev Containers: Reopen in Container`)」を選択してクリックします。

すると、開発コンテナーの `dvc-wordpress`（VS Code の Containers 拡張機能の画面では `dvc-wordpress` プロジェクトの `vsc-dvc-wordpress-（略）` というコンテナー名と表示されるもの。ここでは単純に `dvc-wordpress` コンテナーとします）が起動して、それにアタッチした VS Code の画面が表示されます。

ここからは、`dvc-wordpress` コンテナーの VS Code の画面を使って作業します。

ターミナルを開いて、次のコマンドを実行し、`WordPress` 環境（Webサーバーとデータベース）用のコンテナーである `php-apache` で始まるものが3つ起動していることを確認します。

```bash
$ docker container ls --format "{{.Names}}" | grep php-apache
php-apache-adminer
php-apache
php-apache-mysql
```

この時点では、WordPress 用のファイルを配置する開発用のフォルダが作成されていません。これを用意します。

```bash
docker compose -p dvc-wordpress exec php-apache bash -c "
if [ ! -e /home/node/workspace/php/html/ ]; then \
  mkdir -p /home/node/workspace/php/html/; \
fi \
"
```

次に `WordPress` サイトの初期化設定をします。

起動した `php-apache` コンテナーへ必要なファイルをコピーします。

```bash
docker compose -p dvc-wordpress exec php-apache bash -c "
  cp /var/www/html/init-wp.sh /home/node/workspace/php/html/ 
"
docker compose -p dvc-wordpress exec php-apache bash -c "
  cp /var/www/html/html.code-workspace /home/node/workspace/php/html/
"
```

コピーしたファイルは VS Code で編集できます。これは、`dvc-wordpress` コンテナーと `php-apache` コンテナーは `/home/node/workspace` というパスを Docker ボリュームを使って共有しているからです。

WordPress の初期化用スクリプトは `init-wp.sh` になります。この内容を確認して、変更が必要な場合は調整します。

用意ができたら `init-wp-sh` を実行して `WordPress` とプラグインをインストール、初期化します。`php-apache` の Xdebug を無効化しないと Xdebug の情報が表示されますが、無視して良いです。

```bash
docker compose -p dvc-wordpress exec php-apache bash -c '
  cd /home/node/workspace/php/html/ && WEB_ROOT_DIR=$(pwd) bash init-wp.sh 
'
```

作業が終了したら、`dvc-wordpress` コンテナー内のターミナルで、以下のコマンドを実行して `WordPress` 環境の確認をします。

```bash
docker compose -p dvc-wordpress exec dvc-wordpress \
  curl -L -s http://localhost:8080/ | grep "<title>DevSite</title>"
```

次のように `<title>DevSite</title>` が表示されたら成功です。

```text
<title>DevSite</title>
```

なお、`WordPress` を初期化したい場合は、`init-wp.sh` を再実行します。

### 2.3. サイトへのアクセス

`WordPress` の初期セットアップまで済ませてから、ホストの Web ブラウザから WordPress のサイトを開きます。

| URL                              | 説明           |
| -------------------------------- | -------------- |
| <http://localhost:8080>          | フロントエンド |
| <http://localhost:8080/wp-admin> | 管理画面       |

認証については、初期設定だと次のようになっています。`init-wp.sh` を変更して別のものにした場合は、それを使います。

| 項目       | 初期値    |
| ---------- | --------- |
| ユーザー名 | `user001` |
| パスワード | `pass001` |

## 3. 開発ワークフロー

このプロジェクトでは、開発スタイルに応じて2つのコンテナー環境を使い分けることができます。

### 3.1. 基本スタイル: `dvc-wordpress` コンテナーでの開発 (推奨)

`VS Code` でプロジェクトを開き、「コンテナーで再度開く」で起動する `dvc-wordpress` コンテナーを使用する方法です。**基本的にこちらのスタイルでの開発を推奨します。**

主な特徴は次のとおり。

- **統合された開発体験:** `dvc-wordpress` 起動時に `WordPress` の実行環境 (`php-apache`) も自動的に起動するため、`VS Code` のターミナルから `git`、`php`、`npm` などの開発ツールと、`docker` コマンドの両方を実行でき、コンテナーとホストPCの間を行き来する必要がありません。
- **簡単なデバッグ:** `Xdebug` は、この `dvc-wordpress` コンテナーに接続するよう初期設定されており、`VS Code` のデバッグ機能（`F5`キー）をすぐに利用できます。
- **ソースコード編集:** `WordPress` の全ファイルは `/home/node/workspace/php/html` にマウントされており、編集内容は `php-apache` 環境に即時反映されます。

主な用途は次のとおり。

- `WordPress` のテーマ・プラグインのコーディング (`PHP`, `JS`, `CSS`)
- `git` を使ったバージョン管理
- `npm` を使ったフロントエンドのビルド
- プロジェクト向けの `php` サンプルコードの編集や実行

**WordPress 環境（php-apache）の開始/停止:**

作業を開始する際は、次のコマンドを実行して、`WordPress` 環境を起動してください。

```bash
docker compose -p dvc-wordpress exec dvc-wordpress 
  sh /script/php-apache/start.sh
```

作業を終了する際は、次のコマンドを実行して、`WordPress` 環境を停止してください。コンテナの破棄はしない点に注意すること。

```bash
docker compose -p dvc-wordpress exec php-apache 
  sh /script/php-apache/stop.sh
```

### 3.2. 代替スタイル: `php-apache` コンテナーの独立運用

`dvc-wordpress` 開発コンテナーの `VS Code` 環境を使用せず、`WordPress` 実行環境である `php-apache` コンテナー群を単独で起動・運用する代替手段です。

次の特徴があります

- リソースの最適化: `dvc-wordpress` 開発コンテナーが不要な場合（例：ホストマシンからの CLI 操作、CI/CD環境での利用など）、`php-apache` サービスのみを起動することでリソース消費を抑えることができます。
- 柔軟な環境構築: `dvc-wordpress` を起動せずに `WordPress` 環境を構築したい場合に、`php-apache/compose.yaml` をベースとして利用できます。
- 操作の分離: `WordPress` のソースコード編集はコンテナー内で行えますが、`docker compose up/down` などのコンテナー自体の操作は、ホストPCのターミナルから実行する必要があります。

主な用途:**

- ホストマシンからの `wp-cli` コマンド実行
- CI/CD 環境でのテスト実行
- 特定のトラブルシューティング

## 4. デバッグ

この環境には `Xdebug` が設定済みです。`VS Code` の "Run and Debug" (実行とデバッグ) ビューから `Listen for Xdebug` を選択してデバッグセッションを開始できます。

デバッグ機能の有効/無効化や `dbgpClient` の利用方法などの詳細については、`GEMINI.md` の「5. デバッグ」セクションを参照してください。

## 5. フォルダ構成

プロジェクトのフォルダ構成に関する詳細については、`GEMINI.md` の「6. フォルダ構成」セクションを参照してください。

## 6. composer アップデート

`composer diagnose` を実行すると、Composer の動作チェックができます。

```bash
composer diagnose
```

成功すると次のような結果となります。

```bash
node ➜ ~/workspace $ composer diagnose
Checking pubkeys: 
Tags Public Key Fingerprint: 57815BA2 7E54DC31 7ECC7CC5 573090D0  87719BA6 8F3BB723 4E5D42D0 84A14642
Dev Public Key Fingerprint: 4AC45767 E5EC2265 2F0C1167 CBBB8A2B  0C708369 153E328C AD90147D AFE50952
OK
Checking Composer version: OK
Composer version: 2.9.5
Checking Composer and its dependencies for vulnerabilities: OK
PHP version: 8.2.30
PHP binary path: /home/node/.local/share/mise/installs/php/8.2.30/bin/php
OpenSSL version: OpenSSL 3.5.4 30 Sep 2025
curl version: 8.14.1 libz 1.3.1 brotli brotli/1.1.0 zstd supported ssl OpenSSL/3.5.4 HTTP 1.0, 1.1, 2, 3
zip: extension present, unzip present, 7-Zip not available
Checking platform settings: OK
Checking git settings: OK git version 2.53.0
Checking http connectivity to packagist: OK
Checking https connectivity to packagist: OK
Checking github.com rate limit: OK
Checking disk free space: OK
```

この結果に `FAIL` がある場合は、`composer` がうまく設定されていないということになります。その場合は、次のコマンドを実行します。

```bash
composer self-update --update-keys
```

途中で入力を求められるので、次の URL を開いてキーをコピーして入力します。

- <https://composer.github.io/pubkeys.html>

もしくは次の URL にあるキーをダウンロードして入力します。

- Dev / Snapshot Public Key: <https://composer.github.io/snapshots.pub>
- Tags Public Key: <https://composer.github.io/releases.pub>

```bash
curl -s -L -O https://composer.github.io/snapshots.pub
curl -s -L -O https://composer.github.io/releases.pub
cat snapshots.pub releases.pub > composer_keys.txt
cat composer_keys.txt | script -q -c "composer self-update --update-keys" /dev/null
```

コマンド実行後、再度 `composer diagnose` を実行して `FAIL` が消えたことを確認します。

## 7. 詳細ガイド

環境のカスタマイズ、より詳細なデバッグ方法、その他の技術的な詳細については、以下のドキュメントを参照してください。

- `GEMINI.md`: プロジェクト全体の詳細な開発ガイドです。
- `.devcontainer/README.md`: 開発コンテナー `dvc-wordpress` の設定に関する詳細な説明です。
- `php-apache/README.md`: WordPress コンテナー `php-apache` に関する技術的な詳細説明です。
