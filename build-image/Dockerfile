FROM hiro345g/dvc:202602
# hiro345g/dvc:202602 イメージ作成用の Dockerfile, devcontainer.json は下記を参照すること
# https://github.com/hiro345g/dvc/tree/fe265463531bbb2b53874ba124e94872b0c731a0/dvc/build

RUN apt-get update && apt-get -y upgrade

# Debian パッケージの更新
RUN apt-get update && apt-get -y upgrade

# PHP と関連ツールのインストール
COPY build-image/install-php.sh /usr/local/bin/install-php.sh
RUN sudo -u node sh -c '/bin/sh /usr/local/bin/install-php.sh'

# Composer のインストール
COPY build-image/install-composer.sh /usr/local/bin/install-composer.sh
RUN sudo -u node sh -c '/bin/sh /usr/local/bin/install-composer.sh'

# 不要なファイルの削除
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# PHPの設定を上書き（アップロードサイズ制限の緩和など）
# RUN echo "upload_max_filesize = 64M" >> /usr/local/php/current/etc/php.ini \
#     && echo "post_max_size = 64M" >> /usr/local/php/current/etc/php.ini \
#     && echo "memory_limit = 256M" >> /usr/local/php/current/etc/php.ini