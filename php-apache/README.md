# WordPress 実行環境 (php-apache)

このフォルダには、`WordPress` を実行するための `Docker` 環境 (`php-apache`) の設定ファイルが含まれています。これは `php-apache-core/compose.yaml` を `include` する形で構成されており、`Apache`、`PHP`、`MySQL` を含み、`WordPress` サイトを実際に動作させるためのコンテナ群です。

## 1. はじめに

このドキュメントは `php-apache` 環境の技術的な詳細について説明します。

プロジェクト全体の概要や基本的な使い方については、まずルートフォルダのドキュメントを参照してください。

- **[プロジェクト README (../README.md)](../README.md):** プロジェクトの始め方、全体像。
- **[GEMINI.md (../GEMINI.md)](../GEMINI.md):** より詳細な開発ガイド。

## 2. 環境のビルドと起動

`php-apache` 環境のセットアップの詳細な手順は `GEMINI.md` の「3. 環境構築」セクションを参照してください。

### 2.1. Docker イメージのビルド

`php-apache` 環境の `Docker` イメージは、`build/build.sh` スクリプトを実行することでビルドされます。これにより `dvc-wordpress:php-apache` というタグが付けられたイメージが作成されます。

### 2.2. 環境の起動と停止

以下のスクリプトを使用して、`php-apache` 環境を起動および停止します。

- **起動:** `script/up.sh`
- **停止:** `script/down.sh`

## 3. WordPress のセットアップとデバッグ

`WordPress` の初期インストールやデバッグ方法についても、`GEMINI.md` に詳細な手順が記載されています。

- **WordPress の初期設定:** `GEMINI.md` の「3.5. `WordPress` サイトの初期設定」
- **デバッグ方法:** `GEMINI.md` の「5. デバッグ」

### 3.1. dbgpClient

`VS Code` のデバッガを使わずに `Xdebug` を利用するためのコマンドラインツール `dbgpClient` が php-apache コンテナに含まれています。ちなみに、dvc-wordpress 開発コンテナにも含まれています。

`dbgpClient` を起動しておくと、`WordPress` のインストールスクリプト実行時などに `Xdebug` 関連のエラーが表示されるのを防ぐことができます。

```bash
./dbgpClient
```

- **参考:** [Xdebug: Documentation » Command Line Debug Client](https://xdebug.org/docs/dbgpClient)

## 4. 高度な設定

### 4.1. デバッグ設定の変更

`Xdebug` の有効/無効を切り替える方法や、デバッグホストを変更する方法については、`GEMINI.md` の「5. デバッグ」セクションを参照してください。

### 4.2. データベースの URL 置換

実際に使っている WordPress のサイトのデータを使って動作確認をしたい場合は、サイトのドメインを変更する必要があります。データベース内の URL を一括で置換したい場合は、以下の `SQL` クエリが役立ちます。`adminer` コンテナーなどから実行できます。

この例では `https://www.dev.internal` 用の Web サイトのデータを開発用に `php-apache` で動作するようにする想定です。そのため、`https://www.dev.internal` を `http://localhost` に置換しています。

```sql
UPDATE wp_options SET option_value=REPLACE(option_value, 'https://www.dev.internal', 'http://localhost');
UPDATE wp_posts SET post_content=REPLACE(post_content, 'https://www.dev.internal', 'http://localhost');
UPDATE wp_posts SET guid=REPLACE(guid, 'https://www.dev.internal', 'http://localhost');
UPDATE wp_postmeta SET meta_value=REPLACE(meta_value, 'https://www.dev.internal', 'http://localhost');
```
