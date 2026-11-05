# WordPress 実行環境・開発環境用 Docker 関連ファイル

　このディレクトリには、`dvc-wordpress` プロジェクトで利用可能な Web サーバー、PHP 実行環境、データベース、および周辺ツール（SSL 証明書生成、リバースプロキシなど）のモジュール化された Docker Compose 構成が格納されています。

　これらは開発コンテナ（ワークスペース）から自動的に起動・連動されるほか、個別に開発環境をカスタマイズしたり、テスト用の独立したサーバーとして単体で起動したりすることも可能です。

　イメージをビルドするには、次のようにスクリプト `build-dev-image.sh` を実行します。

```bash
cd ${PROJECT_DIR}
bash ./script/build-dev-image.sh
```

## 1. ディレクトリ構成と各環境の役割

次のフォルダだけ特別で、開発コンテナ用のイメージをビルドするためのものです。

| ディレクトリ名              | 説明                                                        |
| :-------------------------- | :---------------------------------------------------------- |
| `dvc/`                      | 開発コンテナ dvc-wordpress 用                               |

他のものは、WordPress 実行環境・開発環境用のものです。

| ディレクトリ名              | 説明                                                        |
| :-------------------------- | :---------------------------------------------------------- |
| `dev-adminer/`              | 公式 `adminer` イメージ                                     |
| `dev-common/`               | 共通設定用 `compose.yaml`                                   |
| `dev-mariadb/`              | 公式 `mariadb` データベース                                 |
| `dev-mysql/`                | 公式 `mysql` データベース                                   |
| `dev-wp-apache/`            | 公式 `wordpress` イメージ                                   |
| `dev-wp-fpm/`               | 公式 `wordpress` イメージ + カスタマイズ `nginx` イメージ   |
| `dev-php-apache-wp/`        | カスタマイズ `php` イメージ                                 |
| `dev-php-fpm-wp/`           | カスタマイズ `php` イメージ + カスタマイズ `nginx` イメージ |
| `dev-frankenphp-wp/`        | カスタマイズ `frankenphp` イメージ                          |
| `dev-frankenphp-wp-volume/` | カスタマイズ `frankenphp` イメージ                          |
| `mkcert/`                   | 開発用ツール                                                |
| `nginx/`                    | リバースプロキシ用設定                                      |
| `php-apache/`               | カスタマイズ `php` イメージ                                 |
| `php-apache-https/`         | カスタマイズ `php` イメージ                                 |

主な役割は次のとおり。

- `dev-adminer/`: データベースを管理するための Web UI を提供するための Docker Compose 構成です。
- `dev-common/`: 複数環境で共有する外部ネットワーク (`compose-net-external.yaml`)、データベースおよび Adminer の統合起動 (`compose-db.yaml`) を管理します。
- `dev-mariadb/`: MariaDB 12.3 サーバーを単独で起動するための Docker Compose 構成です。
- `dev-mysql/`: MySQL 8.4 サーバーを単独で起動するための Docker Compose 構成です。
- `dev-wp-apache/`: WordPress 公式の `wordpress:php8.3-apache` イメージを使用した、最も手軽なシングルコンテナ構成です。
- `dev-wp-fpm/`: WordPress 公式の `wordpress:php8.3-fpm` を PHP 実行環境とし、フロントに Nginx サーバーを配置した本番に近いマルチコンテナ構成です。
- `dev-php-apache-wp/`: `php:8.3-apache` イメージをベースに、`wp-cli`、Composer、Xdebug などを `Dockerfile` 内で独自ビルドして WordPress を ZIP 展開する高度な開発環境です。
- `dev-php-fpm-wp/`: `php:8.3-fpm` ベースのカスタム PHP-FPM コンテナに、静的ファイルを配信するカスタム Nginx コンテナを連動させた、高パフォーマンス開発構成です。
- `dev-frankenphp-wp/`: Go 言語製の Caddy サーバーを内蔵した最新の PHP 実行環境 `FrankenPHP` を使用し、WordPress 7.0 をクラシックモードで動作させるモダン構成です。
- `dev-frankenphp-wp-volume/`: 開発ワークスペースコンテナの共有ボリューム（`workspace-data`）を直接マウントし、開発中のソースコードをそのまま実行する FrankenPHP 構成です。
- `mkcert/`: ローカル開発用のプライベート CA を構築し、任意のローカルドメイン向けに信頼された HTTPS サーバー証明書を生成・共有する自動化コンテナ構成です。
- `nginx/`: 複数のバックエンド（`php-apache` など）を手前で受け付け、TLS 終端（HTTPS化）や subdirectory ルーティング（例: `/blog/` への転送）を実行する Nginx プロキシ構成です。
- `php-apache/`: 開発コンテナで利用可能な WordPress を動かす Web サーバー + データベースサーバー環境
- `php-apache-https/`: 開発コンテナで利用可能な HTTPS 対応版の WordPress を動かす Web サーバー + データベースサーバーの環境

## 2. `dev-common` による設定の一元化

　このプロジェクトでは、重複する構成を排除するために Docker Compose の `include` 機能を重視しています。

### 共通データベースと Adminer のインクルード (`dev-common/compose-db.yaml`)

例えば、`dev-php-apache-wp` や `dev-frankenphp-wp` などの各 Web サーバー環境の `compose.yaml` では、自身のサービス内にデータベースを定義せず、以下のように `include` パスを指定して共通設定を読み込んでいます。

```yaml
# 各環境の compose.yaml の例
services:
  dev-php-apache-wp:
    # 自身のサーバー設定...

include:
  - ../dev-common/compose-db.yaml # 共通の DB + Adminer 構成をインポート
```

これにより、どのサーバー構成に切り替えても、同じ MariaDB データベースおよび同じ Adminer（ポート `5080`）が透過的に立ち上がり、データをそのまま引き継ぎながら検証作業が行えます。

## 3. 基本的な操作方法

### 特定の環境の単体起動

DVC（開発コンテナ）を起動せず、ホスト PC 側のターミナルから特定のサーバー環境（例：`dev-php-apache-wp`）だけを起動・検証したい場合は、目的のディレクトリに移動して Compose コマンドを実行します。

```bash
# 1. 目的の環境ディレクトリへ移動
cd docker/dev-php-apache-wp/

# 2. バックグラウンドでコンテナ群を起動 (データベースも自動連動)
docker compose up -d

# 3. 起動しているコンテナのステータスを確認
docker compose ps

# 4. 検証が完了したらコンテナを停止・破棄
docker compose down
```

### カスタムイメージの再ビルド

Dockerfile を変更した、または PHP 拡張機能を追加したなどの理由でカスタムイメージを再ビルドしたい場合は、`build` オプションを付与して起動するか、ビルド用のスクリプトを実行します。

```bash
# Docker Compose による再ビルド
docker compose build --no-cache

# または、各ディレクトリ内の build-image/build.sh スクリプトを実行
bash ./build-image/build.sh
```

## 4. セキュリティに関するガイドライン

- uploads ディレクトリでの PHP 実行禁止: 本番のセキュリティ仕様に基づき、`/wp-content/uploads/` ディレクトリ内での PHP スクリプト実行は、Caddyfile または Apache / Nginx 設定によってブロックされています。
- 管理者権限の分離: 各コンテナ（特に開発ワークスペースおよび Apache）は、可能な限り一般ユーザー（`node` や `www-data`）で動作するように権限調整が施されています。
- 証明書の保護: `mkcert` によってローカル生成されたルート CA の秘密鍵（`rootCA-key.pem`）は、セキュリティの観点から、リポジトリに絶対にコミット（プッシュ）しないよう注意してください。
