# .devcontainer

このフォルダには、`VS Code Dev Container` の設定ファイルが含まれています。

## フォルダ構成

Dev Container に関係するファイルについて、説明します。

```text
dvc-wordpress/
├── .devcontainer/
│   ├── devcontainer.json        # Dev Container用設定ファイル
│   ├── README.md                # このファイル
│   ├── sample.env               # 環境変数設定ファイルのサンプル
│   └── script/
│       ├── init.sh              # Dev Container 初期化スクリプト
│       └── php-apache/          # Dev Container 利用時の php-apache 用スクリプト
├── compose.yaml                  # Dev Container を起動するための Docker Compose ファイル
└── workspace_share/              # 開発コンテナーとホストで共有するフォルダ
```

これ以降、`dvc-wordpress` フォルダを `${PROJECT_DIR}` と表記します。

## .devcontainer フォルダ

- `devcontainer.json`: Dev Container の設定ファイルです。
  - `LOCAL_WORKSPACE_FOLDER` 環境変数で、ローカルマシンのワークスペースフォルダのパスをコンテナに渡します。
- `script/init.sh`: Dev Container の初期化時に実行されるスクリプトです。
- `script/php-apache/`: `php-apache` 環境を Dev Container から操作するためのスクリプト群です。`start.sh` と `stop.sh` があります。

## compose.yaml

`${PROJECT_DIR}/.devcontainer/devcontainer.json` では `${PROJECT_DIR}/compose.yaml` を参照しています。これについて説明します。

- `compose.yaml`: Dev Container を起動するための Docker Compose ファイルです。
  - `dvc-wordpress` サービス: 開発コンテナーの本体です。
  - `volumes` の設定で `${PROJECT_DIR:-.}/php-apache` という記述があります。これは、ホストマシンの `php-apache` フォルダをコンテナ内の `/php-apache` にマウントするための設定です。`${PROJECT_DIR:-.}` の部分は、環境変数 `PROJECT_DIR` が設定されていればその値を、未設定の場合はカレントフォルダ (`.`) をプロジェクトのルートパスとして使用します。

## 環境変数

`${PROJECT_DIR}/compose.yaml` では、以下の環境変数が使用されます。これらの変数を設定するには、`${PROJECT_DIR}` フォルダに `sample.env` をコピーして `.env` というファイル名で保存し、そのファイルに必要な値を記述します。

- `PROJECT_DIR`: プロジェクトのルートフォルダのパスを指定します。未設定の場合は、`compose.yaml` があるフォルダ（つまり `${PROJECT_DIR}/`）からの相対パスで解釈されます。
- `SHARE_DIR`: ホストとコンテナで共有するフォルダのパスを指定します。未設定の場合は、`${PROJECT_DIR}/workspace_share` フォルダが使用されます。
- `NPM_CONFIG_USERCONFIG`: `npm` の設定ファイルのパスを指定します。未設定の場合は、コンテナ内の `/home/node/.npmrc` が使用されます。`sample.env` に記載の通り、ホストのファイルをコンテナにマウントして使用するなどのカスタマイズが可能です。

### 設定の確認方法

`.env` ファイルに記述した設定が `compose.yaml` に正しく適用されているかを確認するには、`docker compose config` コマンドを使用します。このコマンドは `${PROJECT_DIR}` で実行してください。

```bash
cd ${PROJECT_DIR}
docker compose config
```

次の内容の `${PROJECT_DIR}/.env` ファイルを用意したとします。

```env
PROJECT_DIR=/home/user001/workspace/dvc-wordpress
SHARE_DIR=/home/user001/workspace/workspace_share
NPM_CONFIG_USERCONFIG=/home/node/.npmrc
```

この場合、`docker compose config` コマンドの実行結果は次のようになります（抜粋）。

```bash
$ docker compose config
name: dvc-wordpress
services:
  dvc-wordpress:
    container_name: dvc-wordpress
    environment:
      # 略
      NPM_CONFIG_USERCONFIG: /home/node/.npmrc
    hostname: dvc-wordpress
    # 略
    volumes:
      # 略
      - type: bind
        source: /home/user001/workspace/dvc-wordpress/php-apache
        target: /php-apache
      - type: bind
        source: /home/user001/workspace/workspace_share
        target: /share
    working_dir: /home/node/workspace
    # 略
```
