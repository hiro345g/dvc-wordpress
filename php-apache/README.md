# WordPress 実行環境 (php-apache)

このフォルダには、`WordPress` を実行するための `Docker` 環境 (`php-apache`) の設定ファイルが含まれています。

`php-apache` は、`Apache`、`PHP`、`MySQL`、`Mailpit` を含み、`WordPress` サイトを実際に動作させるためのコンテナ群です。

## 1. はじめに

このドキュメントは `php-apache` 環境の技術的な詳細について説明します。

プロジェクト全体の概要や基本的な使い方については、まずルートフォルダのドキュメントを参照してください。

- **[プロジェクト README (../README.md)](../README.md):** プロジェクトの始め方、全体像。
- **[GEMINI.md (../GEMINI.md)](../GEMINI.md):** より詳細な開発ガイド。

## 2. 環境のビルドと起動

`php-apache` 環境のセットアップは、基本的にプロジェクトルートの `Dev Container` 環境内からスクリプトを実行することで行います。

詳細な手順は `GEMINI.md` の「3. 環境構築」セクションを参照してください。

- **Docker イメージのビルド:** `build/build.sh`
- **起動:** `script/up.sh`
- **停止:** `script/down.sh`

## 3. WordPress のセットアップとデバッグ

`WordPress` の初期インストールやデバッグ方法についても、`GEMINI.md` に詳細な手順が記載されています。

- **WordPress の初期設定:** `GEMINI.md` の「3.5. `WordPress` サイトの初期設定」
- **デバッグ方法:** `GEMINI.md` の「5. デバッグ」

### 3.1. dbgpClient

`VS Code` のデバッガを使わずに `Xdebug` を利用するためのコマンドラインツール `dbgpClient` がコンテナに含まれています。

`dvc-wordpress` コンテナ内で使用したい場合は、以下のコマンドでコピーできます。

```bash
docker compose -p php-apache cp php-apache:/usr/local/bin/dbgpClient ./dbgpClient
```

`dbgpClient` を起動しておくと、`WordPress` のインストールスクリプト実行時などに `Xdebug` 関連のエラーが表示されるのを防ぐことができます。

```bash
./dbgpClient
```

- **参考:** [Xdebug: Documentation » Command Line Debug Client](https://xdebug.org/docs/dbgpClient)

## 4. 高度な設定

### 4.1. デバッグ設定の変更

`Xdebug` の有効/無効を切り替える方法や、デバッグホストを変更する方法については、`GEMINI.md` の「5. デバッグ」セクションを参照してください。

### 4.2. データベースの URL 置換

サイトのドメインを変更する場合など、データベース内の URL を一括で置換したい場合は、以下の `SQL` クエリが役立ちます。`adminer` コンテナーなどから実行できます。

この例では `https://www.dev.internal` 用の Web サイトのデータを開発用に `php-apache` で動作するようにする想定としています。そのため、`https://www.dev.internal` を `http://localhost` に置換しています。

```sql
UPDATE wp_options SET option_value=REPLACE(option_value, 'https://www.dev.internal', 'http://localhost');
UPDATE wp_posts SET post_content=REPLACE(post_content, 'https://www.dev.internal', 'http://localhost');
UPDATE wp_posts SET guid=REPLACE(guid, 'https://www.dev.internal', 'http://localhost');
UPDATE wp_postmeta SET meta_value=REPLACE(meta_value, 'https://www.dev.internal', 'http://localhost');
```
