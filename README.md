# WordPress 開発環境 (dvc-wordpress)

このプロジェクトは、`Docker` と `VS Code Dev Container` を利用して、モダンな `WordPress` の開発環境を構築・提供します。

開発者全員が `PHP`、`Apache`、`Xdebug` などを含む統一された実行環境を簡単に利用できるため、環境差異による問題を解消し、開発に集中できます。

このプロジェクトについて、次の URL で解説記事を公開しています。

- [PHP 開発環境と実行環境を統合して WordPress 開発を効率化](https://zenn.dev/hiro345/articles/20250719_dvc_wordpress)

## 1. 主な特徴

- **統一された開発環境:** `Docker` と `Dev Container` により、OS に依存しない一貫した開発環境を提供します。
- **`WordPress` 実行環境:** `Apache` と `PHP` がセットアップ済みの `WordPress` 実行環境 (`php-apache`) を同梱しています。
- **デバッグ対応:** `Xdebug` を設定済みで、`VS Code` からすぐにステップ実行などのデバッグが可能です。
- **簡単なセットアップ:** シェルスクリプトを実行するだけで、環境の構築から `WordPress` の初期設定までを自動化できます。
- **カスタマイズ可能:** `Dockerfile` や設定ファイルを変更することで、`PHP` のバージョンや `Apache` の設定を自由にカスタマイズできます。

## 2. 始め方

### 2.1. 前提条件

開発を始める前に、お使いの PC に以下のツールがインストールされている必要があります。

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

### 2.2. 環境構築

以下の手順で開発環境を構築します。

1. リポジトリをクローン
2. `WordPress` 用の `Docker` イメージをビルド
3. `Dev Container` を起動
4. `WordPress` 環境を起動
5. `WordPress` の初期セットアップ

**1. リポジトリをクローン:**

```bash
git clone <repository-url>
cd dvc-wordpress
```

**2. `WordPress` 用の `Docker` イメージをビルド:**

`WordPress` を実行するための `Docker` イメージをビルドします。

```bash
bash ./php-apache/build/build.sh
```

**3. `Dev Container` を起動:**

`VS Code` でこのプロジェクトフォルダを開き、表示される通知から「コンテナーで再度開く (Reopen in Container)」を選択するか、コマンドパレット (`Ctrl+Shift+P` または `Cmd+Shift+P`) から「開発コンテナー：コンテナーで再度開く (`Dev Containers: Reopen in Container`)」を選択してクリックします。

**4. `WordPress` 環境を起動:**

`Dev Container` 内のターミナルで、以下のコマンドを実行して `WordPress` (Web サーバー, DB) を起動します。

```bash
/php-apache/script/up.sh
```

**5. `WordPress` の初期セットアップ:**

初回起動時のみ、`WordPress` のダウンロードや初期設定を行います。WordPress サイト管理者のアカウント名やパスワードを変更する場合は `init-wp.sh` を修正してから実行してください。

```bash
# php-apache コンテナーに入る
docker compose -p php-apache exec php-apache bash

# コンテナー内で初期化スクリプトを実行
cp /var/www/html/init-wp.sh /home/node/workspace/php/html/
cd /home/node/workspace/php/html/
WEB_ROOT_DIR=$(pwd) bash init-wp.sh
exit
```

### 2.3. サイトへのアクセス

`WordPress` の初期セットアップまで済ませてから、ホストの Web ブラウザから WordPress のサイトを開きます。

- **サイト URL:** [http://localhost:8080](http://localhost:8080)
- **管理画面:** [http://localhost:8080/wp-admin](http://localhost:8080/wp-admin)
  - **ユーザー名:** `user001` (変更していない場合)
  - **パスワード:** `pass001` (変更していない場合)

## 3. 開発ワークフロー

このプロジェクトでは、開発スタイルに応じて2つのコンテナ環境を使い分けることができます。

### 3.1. 基本スタイル: `dvc-wordpress` コンテナでの開発 (推奨)

`VS Code` でプロジェクトを開き、「コンテナーで再度開く」で起動する `dvc-wordpress` コンテナを使用する方法です。**基本的にこちらのスタイルでの開発を推奨します。**

- **特徴:**
  - **統合された開発体験:** `VS Code` のターミナルから `git`、`php`、`npm` などの開発ツールと、`docker` コマンドの両方を実行できます。`WordPress` の実行環境 (`php-apache`) の操作も同じウィンドウ内で完結するため、コンテナとホストPCの間を行き来する必要がありません。
  - **簡単なデバッグ:** `Xdebug` は、この `dvc-wordpress` コンテナに接続するよう初期設定されています。`VS Code` のデバッグ機能（`F5`キー）をすぐに利用できます。
  - **ソースコード編集:** `WordPress` の全ファイルは `/home/node/workspace/php/html` にマウントされており、編集内容は `php-apache` 環境に即時反映されます。
- **主な用途:**
  - `WordPress` のテーマ・プラグインのコーディング (`PHP`, `JS`, `CSS`)
  - `git` を使ったバージョン管理
  - `npm` を使ったフロントエンドのビルド
  - プロジェクト向けの `php` サンプルコードの編集や実行

### 3.2. 代替スタイル: `php-apache` コンテナへの直接アタッチ

マシンのスペックなど、何らかの理由で `dvc-wordpress` 開発コンテナと `php-apache` コンテナの両方の同時起動が難しい場合の代替手段です。`VS Code` の `Docker` 拡張機能から、実行中の `php-apache` コンテナに直接 `Attach Visual Studio Code` して開発します。

- **特徴:**
  - **省リソース:** `dvc-wordpress` コンテナを起動しないため、`Docker` が消費するリソースを抑えることができます。
  - **実行環境での直接操作:** `wp-cli` コマンドの実行や、`Apache` のログ確認など、`WordPress` が動作している環境そのもので作業できます。
- **注意点:**
  - **操作の分離:** ソースコードの編集はコンテナ内で行いますが、`docker compose up/down` などのコンテナ自体の操作は、ホストPCのターミナルから実行する必要があります。
  - **デバッグ設定の変更:** このスタイルで `VS Code` のデバッガを使用するには、`Xdebug` の接続先を `php-apache` コンテナ自身に向ける設定変更が**必須**です。詳細は `php-apache/README.md` を参照してください。

## 4. 開発環境の詳細ガイド

環境のカスタマイズ、デバッグ方法、フォルダ構成などの詳細については、以下のドキュメントを参照してください。

- **[GEMINI.md](./GEMINI.md):** プロジェクト全体の詳細な開発ガイドです。
- **[.devcontainer/README.md](./.devcontainer/README.md):** Dev Container の設定に関する詳細な説明です。
- **[php-apache/README.md](./php-apache/README.md):** WordPress 実行環境 (`php-apache`) に関する技術的な詳細説明です。
