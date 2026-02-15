#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
BASE_DIR=$(cd "${SCRIPT_DIR}/.." || exit 1;pwd)

# 開発コンテナー用イメージ `dvc-wordpress:php-202602` のビルド
bash "${BASE_DIR}/build-image/build.sh"

# WordPress 用イメージ `dvc-wordpress:php-apache` のビルド
bash "${BASE_DIR}/php-apache/build/build.sh"

# ビルドが成功したら、使用する Docker オブジェクトの初期化
# Docker オブジェクトがすでにある場合は初期化処理は自動スキップ
bash "${BASE_DIR}/php-apache/script/up.sh"

# 起動の確認
if docker compose ls | grep php-apache > /dev/null; then
  # `php-apache` 向けサービスが起動したら、使用する Docker オブジェクトの初期化は成功
  :
else
  # `php-apache` 向けサービスが起動していない場合は、使用する Docker オブジェクトの初期化が失敗
  echo "error" || exit 1
fi

# 確認ができたら、php-apache プロジェクトで起動したコンテナーを破棄
bash "${BASE_DIR}/php-apache/script/down.sh"
