# dvc-wordpress/build-image

## プロジェクト概要

このフォルダは、`dvc-wordpress` 開発コンテナーで使用する `PHP` 環境を構築するための `Docker` イメージをビルドするためのファイルを含んでいます。`mise` を使用して `PHP` のバージョンを管理し、安定した開発環境を提供します。

## イメージのビルド

`dvc-wordpress` 開発コンテナーの `Docker` イメージをビルドするには、以下の手順を実行します。

### 1. `mise` 環境の準備

`mise` を使用して `PHP` 環境をセットアップします。`build.sh` スクリプトは、コンテナー内で自動的に `mise` を初期化し、指定された `PHP` バージョンをインストールします。

ベースイメージに devcontainers の features にある php を使っている `hiro345g/dvc:php-202602` を採用していない理由は、`PHP` のビルドオプションの指定が設定できずに固定となるからです。そのため、使いたい `PHP` の拡張機能があったときに、対応しやすい `mise` を採用することにしました。

### 2. イメージのビルドスクリプトの実行

プロジェクトのルートディレクトリ (`${PROJECT_DIR}`) で、以下のコマンドを実行して `Docker` イメージをビルドします。

```bash
cd ${PROJECT_DIR}
bash ./build-image/build.sh
```

このスクリプトは、`build-image/Dockerfile` に基づいてイメージをビルドし、`dvc-wordpress:php-202602` というタグを付けます。
