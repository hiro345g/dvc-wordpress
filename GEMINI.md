# WordPress 開発環境ガイド

## 1. プロジェクト概要

このプロジェクトは、`Docker` と `VS Code Dev Container` を利用して、`WordPress` の開発環境を構築・提供します。

Dev Container により、開発者全員が統一された `PHP`、`Apache`、`Xdebug` などの実行環境を簡単に利用できます。

## 2. 前提条件

開発を始める前に、お使いの PC に以下のツールがインストールされている必要があります。

- [Node.js](https://nodejs.org/ja/)
- `Docker`
  - [Docker Engine](https://docs.docker.com/engine/)
  - [Docker Compose](https://docs.docker.com/compose/)
- [Visual Studio Code](https://code.visualstudio.com/)

`Docker` については、[Docker Desktop](https://docs.docker.com/desktop/) でも良いです。`Docker Desktop` には `Docker Engine` と `Docker Compose` が含まれているからです。

また、次の `VS Code` 拡張機能もインストールしておいてください。

- [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- [Container Tools](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-containers)
- [Docker DX](https://marketplace.com/items?itemName=docker.docker)
- [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## 3. 環境構築

このプロジェクトでは、`PHP` プログラミング用の開発コンテナー `dvc-wordpress` と `WordPress` の開発に使えるコンテナー `php-apache` を用意してあります。どちらのコンテナーを使うのかは、用途によって変わります。

それぞれの環境の特徴については、次のとおりです。

- `dvc-wordpress`: `PHP` のコード開発、単体 `PHP` プログラムの実行用環境
- `php-apache`: `Apache` + `WordPress` の実行環境と必要な `Apache` モジュール、`PHP` モジュールのインストールがされた環境

開発コンテナー用イメージのビルド、WordPress コンテナー用イメージのビルド、Docker オブジェクトの初期化のために、以下のコマンドを順番に実行します。これは `dvc-wordpress` 開発コンテナーを起動する前の準備として行います。

```bash
cd ${PROJECT_DIR}
bash ./build-image/build.sh
bash ./php-apache/build/build.sh
bash ./php-apache/script/up.sh
bash ./php-apache/script/down.sh
```

このコマンドブロックには、`php-apache`が単体で動作するかを確認するテストが含まれています。必須ではありませんが、事前に行うと問題の切り分けに役立ちます。

それでは、説明します。

### 3.1. **`VS Code` でプロジェクトを開く**

このリポジトリをクローンした後、`VS Code` で `dvc-wordpress` のプロジェクトのルートフォルダを開きます。これ以降、このルートフォルダを `${PROJECT_DIR}` とします。

### 3.2. 必要な Docker イメージのビルドと初回セットアップ

初めて開発コンテナーを起動する前に、開発コンテナー用イメージ (`dvc-wordpress:php-202602`) のビルドが必要です。

```bash
cd ${PROJECT_DIR}
bash ./build-image/build.sh
```

また、`WordPress` 開発用のコンテナー向けの `Docker` イメージ `dvc-wordpress:php-apache` をビルドします。ビルドには `php-apache/build/build.sh` スクリプトを使用するのが主要な方法です。このビルドにより、以下の初期設定が自動的に行われた `Docker` イメージが用意できます。

- `Apache` の設定
- `WordPress` サイトの初期化ができる環境
- その他、開発に必要なツールのインストール

```bash
cd ${PROJECT_DIR}
bash ./php-apache/build/build.sh
```

カスタマイズする場合は、`build` にある `Dockerfile` や関連ファイルを修正して使います。

ビルドが成功したら、`Docker Compose` プロジェクトの `php-apache` 向けサービスを起動します。これで、このプロジェクトで使用する Docker オブジェクトの初期化がされます。

```bash
cd ${PROJECT_DIR}
bash ./php-apache/script/up.sh
```

`docker compose ls` コマンドで、`php-apache` プロジェクトが `running` となっていることを確認します。`grep` コマンドが使えない環境の場合は、一覧表示される中から該当する行を探してください。

```bash
docker compose ls | grep php-apache
```

ホスト環境が `Ubuntu` の場合の実行例は、次のようになります。

```bash
$ docker compose ls | grep php-apache
php-apache    running(3)    （略）/dvc-wordpress/php-apache/compose.yaml
```

起動が成功していたら、停止します。

```bash
cd ${PROJECT_DIR}
bash ./php-apache/script/down.sh
```

### 3.4. **`Dev Container` の起動**

`Dev Container` の起動方法はいくつかあります。次のどれかで `Dev Container` を起動します。

- `VS Code` でプロジェクトを開くと、右下に「コンテナーで再度開く（Reopen in Container）」という通知が表示されます。このボタンをクリック
- コマンドパレット (`Ctrl+Shift+P` または `Cmd+Shift+P`) を開き、「開発コンテナー：コンテナーで再度開く（`Dev Containers: Reopen in Container`）」を表示してクリック
- `VS Code` の左下角の部分をクリックすると表示されるメニューで「コンテナーで再度開く」をクリック

いずれかの方法で `dvc-wordpress` 開発コンテナーを起動すると、`WordPress` 実行環境である `php-apache` および関連するデータベースサービス（MySQL）が自動的に起動します。

### 3.5. **`WordPress` 実行環境の起動確認**

次のコマンドを実行して `WordPress` 環境（Webサーバーとデータベース）の起動を確認します。

```bash
$ docker container ls --format "{{.Names}}" | grep php-apache
php-apache-adminer
php-apache
php-apache-mysql
```

開発用のフォルダを作成します。

```bash
docker compose -p dvc-wordpress exec php-apache bash -c "\
    if [ ! -e /home/node/workspace/php/html/ ]; then mkdir -p /home/node/workspace/php/html/; fi \
"
```

### 3.6. **`WordPress` サイトの初期設定**

起動した `dvc-wordpress` 開発コンテナー内から `php-apache` サービスに対して、`WordPress` サイトの初期設定をします。このとき、デバッグ機能を無効化しておくと、余計なメッセージが表示されなくなります。デバッグ機能の無効化については、後述する `5. デバッグ - 5.1. デバッグ機能の無効化` を参照してください。

`WordPress` サイトの初期設定をするには、次の作業が必要です。

- `WordPress` のダウンロードと展開
- `wp-config.php` の生成
- プラグインのインストールと初期設定

次のコマンドを実行して必要なファイルをコピーします。

```bash
docker compose -p dvc-wordpress exec php-apache bash -c "\
    cp /var/www/html/init-wp.sh /home/node/workspace/php/html/ \
"
docker compose -p dvc-wordpress exec php-apache bash -c "\
    cp /var/www/html/html.code-workspace /home/node/workspace/php/html/ \
"
```

それから、`init-wp.sh` を実行して、`WordPress` とプラグインをインストールし、それから初期化もします。

```bash
docker compose -p dvc-wordpress exec php-apache bash -c '\
    cd /home/node/workspace/php/html/ && WEB_ROOT_DIR=$(pwd) bash init-wp.sh \
'
```

`WordPress` の初期化についてカスタマイズをしたい場合は `init-wp.sh` を修正してください。ここでは、`all-in-one-wp-migration`、`backwpup`、`query-monitor` のプラグインをインストールしてあります。

作業が終了したら、`Dev Container` 内のターミナルで、以下のコマンドを実行して `WordPress` 環境（Webサーバーとデータベース）の確認をします。

```bash
docker compose -p dvc-wordpress exec dvc-wordpress curl -L -s http://localhost:8080/ | grep "<title>DevSite</title>"
```

次のように `<title>DevSite</title>` が表示されたら成功です。

```bash
$ docker compose -p dvc-wordpress exec dvc-wordpress curl -L -s http://localhost:8080/ | grep "<title>DevSite</title>"
<title>DevSite</title>
```

参考までに、`WordPerss` 用のデータは、次の `Docker` ボリュームに保存されています。

- `dvc-wordpress-php-apache-mysql-data` ... DB のデータ
- `dvc-wordpress-home-node-workspace-data` ... `php/html` フォルダに `WordPress` のファイル

なお、`WordPress` を初期化したい場合は、`init-wp.sh` を再実行します。開発するプログラムによっては、完全な初期化をせずにしたい場合もあるでしょう。その場合は、`init-wp.sh` を修正して使うようにしてください。

## 4. 開発

dvc-wordpress を起動して開発している前提で説明します。

### 4.1. `WordPress` 環境の開始

`dvc-wordpress` 開発コンテナーの起動時に `WordPress` 環境 (`php-apache` サービス) は自動的に起動するため、通常このコマンドは不要です。もし開発中に意図的にサービスを停止した場合は、次のコマンドを実行して再度 `WordPress` 環境を起動してください。

```bash
docker compose -p dvc-wordpress exec dvc-wordpress \
    sh /script/php-apache/start.sh
```

### 4.2. `WordPress` サイトへのアクセス

`WordPress` 環境を起動すると、次の `URL` で `WordPress` のサイトへアクセスすることができるようになります。ユーザー名とパスワードは `init-wp.sh` で指定したものになります。ここでは初期に用意してある `init-wp.sh` をそのまま使った場合のものを示しています。

- **フロントエンド**: [http://localhost:8080](http://localhost:8080)
- **管理画面**: [http://localhost:8080/wp-admin](http://localhost:8080/wp-admin)
  - **ユーザー名**: `user001`
  - **パスワード**: `pass001`

### 4.3. ファイルの編集

`WordPress` のソースコードは `Docker` ボリュームの `dvc-wordpress-home-node-workspace-data` 内の `php/html` フォルダに保存されます。これは、`dvc-wordpress` 開発コンテナーと `php-apache` コンテナーの両方から `/home/node/workspace/php/html/` のパスでアクセスできるようになっています。このフォルダ内のファイルを編集すると、すぐに `Web` サイトに反映されます。

### 4.4. `WordPress` 環境の停止

`dvc-wordpress` 開発コンテナーを終了すれば、`WordPress` 環境 (`php-apache` サービス) も自動的に停止します。開発コンテナーを起動したまま、一時的に `WordPress` 環境のみを停止したい場合は、次のコマンドを実行してください。

```bash
docker compose -p dvc-wordpress exec php-apache \
    sh /script/php-apache/stop.sh
```

## 5. デバッグ

この環境には `Xdebug` が設定済みです。`VS Code` の "Run and Debug" (実行とデバッグ) ビューから `Listen for Xdebug` を選択してデバッグセッションを開始できます。また、`VS Code` を使わなくても `dbgpClient` コマンドを使うことでターミナルでデバッガの実行ができるようにしてあります。

### 5.1. デバッグ機能の無効化

`php-apache` で `PHP` のプログラムを実行するときに、デバッグ機能が有効になっていてデバッガが起動していないと、デバッグ関連の警告やエラーのメッセージが表示されてしまいます。これを抑制するには、次のコマンドを実行してデバッグ機能を無効化します。

```bash
docker compose -p dvc-wordpress exec php-apache \
    mv /usr/local/etc/php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini.disabled
docker compose -p dvc-wordpress exec php-apache \
    kill -HUP 1
```

`php-apache` コンテナー内で `kill -HUP 1` を実行するため、`php-apache` 用のプロセスが再起動される点に注意してください。`php-apache` コンテナーにアタッチしていたターミナルなどがあると、そちらのアタッチは強制終了されるといった影響があります。

デバッグ機能が無効化できたが確認するには、`php-apache` コンテナー内で `php --ini` コマンドを実行します。表示される一覧に `xdebug.ini` を含む行がなければ無効化できています。

```bash
docker compose -p dvc-wordpress exec php-apache \
    php --ini
```

### 5.2. デバッグ機能の有効化

デバッグ機能を有効化するには無効化の逆の手順を踏みます。具体的には次のコマンドを実行します。

```bash
docker compose -p dvc-wordpress exec php-apache \
    mv /usr/local/etc/php/conf.d/xdebug.ini.disabled /usr/local/etc/php/conf.d/xdebug.ini
docker compose -p dvc-wordpress exec php-apache \
    kill -HUP 1
```

**`php --ini` 実行例:**

次に `php --ini` 実行例を示します。この例ではデバッグ機能は有効化されていて、`xdebug.ini` を含む行が表示されていて、この設定が読み込まれていることがわかります。無効化したときは、この行は一覧に表示されません。

```bash
$ docker compose -p dvc-wordpress exec php-apache php --ini
Configuration File (php.ini) Path: /usr/local/etc/php
Loaded Configuration File:         /usr/local/etc/php/php.ini
Scan for additional .ini files in: /usr/local/etc/php/conf.d
Additional .ini files parsed:      /usr/local/etc/php/conf.d/docker-php-ext-bcmath.ini,
/usr/local/etc/php/conf.d/docker-php-ext-exif.ini,
/usr/local/etc/php/conf.d/docker-php-ext-gd.ini,
/usr/local/etc/php/conf.d/docker-php-ext-imagick.ini,
/usr/local/etc/php/conf.d/docker-php-ext-mysqli.ini,
/usr/local/etc/php/conf.d/docker-php-ext-opcache.ini,
/usr/local/etc/php/conf.d/docker-php-ext-pdo_mysql.ini,
/usr/local/etc/php/conf.d/docker-php-ext-sodium.ini,
/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini,
/usr/local/etc/php/conf.d/docker-php-ext-zip.ini,
/usr/local/etc/php/conf.d/opcache-recommended.ini
/usr/local/etc/php/conf.d/xdebug.ini
```

### 5.3. `dbgpClient`

`x86_64` 版の `dbgpClient` が `Docker` イメージには含まれます。`php-apache` 起動後に、`dvc-wordpress` で使いたいときはコピーして使えます。

```bash
docker compose -p dvc-wordpress \
    cp php-apache:/usr/local/bin/dbgpClient ./dbgpClient
```

`VS Code` のデバッガを起動せずに、こちらを起動しておくと、`WordPress` インストール時にデバッガ関連のエラーメッセージが表示されなくなります。

```bash
./dbgpClient 
```

実行例は次

```bash
node ➜ ~/workspace/php/html $ ./dbgpClient 
Xdebug Simple DBGp client (0.6.1)
Copyright 2019-2024 by Derick Rethans

Waiting for debug server to connect on port 9003.
```

デバッガに接続があって、実行を進めたいときは `run` コマンドを実行。

```bash
run
```

- 参考： [Xdebug: Documentation » Command Line Debug Client](https://xdebug.org/docs/dbgpClient)

## 6. フォルダ構成

```text
dvc-wordpress/
├── .devcontainer/
│   ├── devcontainer.json        # Dev Container用設定ファイル
│   └── script/
│       ├── init.sh               # Dev Container 初期化スクリプト
│       └── php-apache/           # Dev Container 利用時の php-apache 用スクリプト
│           ├── start.sh
│           └── stop.sh
├── GEMINI.md                      # この開発ガイド
├── README.md                      # プロジェクトの README
├── app001/                        # WordPress フォルダ内に PHP アプリケーションをデプロイするサンプル用プログラム
│   └── webroot/
│       ├── .htaccess
│       ├── app001/
│       │   ├── .htaccess
│       │   ├── index.php         # アプリケーションのエントリポイント
│       │   ├── info.php          # PHP 情報表示ファイル
│       │   └── static/
│       │       ├── style.css     # 静的ファイルの共通スタイルシート
│       │       ├── index.html    # 静的ファイルのインデックスページ
│       │       └── sample.html   # 静的ファイルのサンプルページ
├── compose.yaml                   # Dev Container を起動するための Docker Compose ファイル
├── php-apache/                    # WordPress 実行環境 (Apache, PHP, MySQL) の設定
│   ├── build/                    # php-apache コンテナーの Docker イメージをビルドするための設定
│   │   ├── .dockerignore
│   │   ├── Dockerfile           # Docker イメージの定義
│   │   ├── build.sh             # ビルドスクリプト
│   │   ├── compose.yaml         # ビルド時に使用する Docker Compose ファイル
│   │   ├── init-wp.sh           # WordPress の初期セットアップスクリプト
│   │   ├── etc_apache2/         # Apache の設定ファイル
│   │   ├── html.code-workspace  # dvc-wordpress:/home/node/workspace/php/html/ に置いて使うワークスペースファイルの例
│   │   ├── sample.env           # ビルド時の環境設定ファイルのサンプル
│   │   └── usr_local_etc_php/   # PHP の設定ファイル
│   ├── compose.yaml              # dvc-wordpress を使わないときに WordPress, DB 用サービスを利用するときに使用
│   ├── php-apache-core/
│   │    └── compose.yaml        # WordPress, DB 用サービスの定義
│   └── script/                   # php-apache 環境の起動・停止スクリプト
│       ├── down.sh
│       ├── start.sh
│       ├── stop.sh
│       └── up.sh
└── workspace_share/               # 開発コンテナーとホストで共有するフォルダ
```

## 7. Markdown スタイルガイド

今後、このプロジェクトの Markdown ファイルを編集する際は、以下のスタイルガイドに従ってください。

### 7.1. 見出し

- `#` (h1) はドキュメントのタイトルにのみ使用し、ファイルごとに1つだけ配置します。
- `##` (h2) は主要なセクションに使用します。
- `##` (h2) のセクション内で項目を立てる際は、番号付きリスト (`1.`, `2.`) ではなく、`###` (h3) を使用します。
- `###` (h3) はサブセクションに使用し、`3.1.` のように親セクションの番号を含めた階層的な番号を付けます。
- `####` (h4) の見出しは使わない。ただし、次の項目で示す方法で同じ内容を表現可能とします。
- `####` (h4) の見出しが必要な場合は、最初に `1. 見出しA` のように (h4) の見出しにする項目の一覧を提示します。その後、各見出しの内容は `**1. 見出しA:**` のフォーマットで見出しを付けてから記述します。  
- 各見出しの後には必ず空行を1行入れます。

### 7.2. リスト

- 番号付きリスト (`1.`, `2.`) および箇条書きリスト (`-`) のマーカーの後には、半角スペースを1つだけ挿入します。(MD030)
- ネストされたリストは、親リストのインデントに合わせて適切にインデントします。

### 7.3. コードブロック

- コードブロックの前後には必ず空行を1行入れます。(MD031)
- ` ``` ` でコードを囲む際は、`bash` や `text` などの言語指定を明記します。
- 長いコマンドは、バックスラッシュ `\` を使って複数行に分割し、可読性を高めます。

### 7.4. インライン要素

- 日本語の文章中に `command` のようなインラインコードや `English` のような英単語を記述する場合は、その前後に半角スペースを挿入し、可読性を高めます。
- URL は `[表示テキスト](URL)` の形式で記述します。

### 7.5. 段落

- 段落間には空行を1行入れます。

### 7.6. 内容と構成

- **補足説明の活用:** コマンドや手順の前後には、その目的や注意点を説明する文章を追加します。（例：「シェルが使えない環境では〜」「〜という影響があります」）
- **コマンド実行例の提示:** コマンドだけでなく、その実行結果の例も ` ``` ` ブロックで示すことで、ユーザーが期待する結果をイメージしやすくします。（例：`docker compose ls` の実行結果）
- **専門用語の定義:** 専門用語やプロジェクト固有の名称（例：`${PROJECT_DIR}`）を導入する際は、その定義を明確にします。
- **セクション間の相互参照:** 関連する情報が別のセクションにある場合、「後述する `X.X.` を参照してください」のように、明確に参照先を示します。
- **フォルダ構成の記述:** フォルダ構成を示す際は、ルートフォルダは `.` ではなく、プロジェクト名 (`dvc-wordpress/`) から記述を開始します。

### 7.7. ファイル構造

- ファイルの末尾には、必ず空行を1行だけ挿入します。(MD047)
- ファイルの末尾に空行が複数ある場合は1行だけにします。(MD012)

### 7.8. フォルダ構成

- ルートフォルダは `.` ではなく、プロジェクト名 (`dvc-wordpress/`) から記述を開始します。                                                        │
