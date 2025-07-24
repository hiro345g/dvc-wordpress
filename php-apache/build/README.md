# Docker Image Build (php-apache/build)

このフォルダには、`php-apache` サービスで使用される `dvc-wordpress:php-apache` Docker イメージをビルドするためのファイルが含まれています。

説明に当たり、これ以降、プロジェクト全体のルートフォルダを `${PROJECT_DIR}` と表記します。

## 概要

`php-apache` 環境は、ここで定義された `Dockerfile` を基に構築されたカスタムイメージ上で動作します。このイメージには、`Apache`、`PHP`、および `WordPress` の実行に必要な拡張機能や設定がすべて含まれています。

プロジェクトのセットアップ時に `${PROJECT_DIR}` フォルダをカレントとして、`bash ./php-apache/build/build.sh` を実行すると、このフォルダ内の設定を使用してイメージがビルドされます。

## ファイル構成

- `build.sh`: Docker イメージのビルドを実行するメインスクリプトです。内部で `docker compose -f build/compose.yaml build` を実行します。
- `compose.yaml`: イメージビルド専用の `Docker Compose` ファイルです。
- `Dockerfile`: `php-apache` イメージの定義ファイルです。ベースイメージ、PHP 拡張機能のインストール、設定ファイルのコピーなどを行います。
- `init-wp.sh`: `WordPress` のダウンロード、設定、プラグインのインストールを行う初期化スクリプトです。ビルド時にイメージ内へコピーされます。
- `etc_apache2/`: `Apache` の設定ファイルが格納されています。ビルド時にイメージ内へコピーされます。
- `usr_local_etc_php/`: `PHP` の設定ファイル (`php.ini`, `xdebug.ini` など) が格納されています。ビルド時にイメージ内へコピーされます。
- `sample.env`: ビルド時に使用する環境変数のサンプルです。

## カスタマイズ

`WordPress` のバージョン、`PHP` の拡張機能、`Apache` の設定などを変更したい場合は、このフォルダ内のファイルを編集して、再度ビルドスクリプトを実行してください。

- **PHPのバージョンや拡張機能の変更:** `Dockerfile` を編集します。
- **WordPressの初期設定の変更:** `init-wp.sh` を編集します。
- **Apache/PHPの設定変更:** `etc_apache2/` や `usr_local_etc_php/` 内のファイルを編集します。

## 関連ドキュメント

- **[php-apache README（${PROJECT_DIR}/php-apache/README.md）](../README.md):** `php-apache` 環境全体の詳細について説明しています。
- **[プロジェクト開発ガイド (${PROJECT_DIR}/GEMINI.md)](../../GEMINI.md):** プロジェクト全体のセットアップと開発フローについて説明しています。
