#!/bin/sh

# set -x

# LAMP アプリでよく使うパッケージのインストール
sudo apt-get install -y --no-install-recommends \
    ghostscript \
    less \
    ssh-client \
    mariadb-client

# PHP と PHP 用モジュールで必要なパッケージのインストール
sudo apt-get install -y --no-install-recommends \
    autoconf \
    bison \
    build-essential \
    curl \
    gettext \
    git \
    libargon2-dev \
    libgd-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libicu-dev \
    libjpeg-dev \
    libmariadb-dev-compat \
    libmariadb-dev \
    libonig-dev \
    libpng-dev \
    libpq-dev \
    libreadline-dev \
    libsodium-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libzip-dev \
    openssl \
    pkg-config \
    re2c \
    zlib1g-dev

# WordPress 用とその他で必要なパッケージのインストール
sudo apt-get install -y --no-install-recommends \
    wget \
    unzip \
    libfreetype6-dev \
    libmagickwand-dev

# ビルドオプションを指定してインストール
/bin/bash -c '\
    export PHP_CONFIGURE_OPTIONS="\
        --enable-gd \
        --with-pdo-mysql \
        --with-mhash --with-pic --enable-mbstring --enable-mysqlnd \
        --with-password-argon2 --with-sodium=shared \
        --with-curl --with-iconv --with-openssl --with-readline \
        --with-zlib --disable-phpdbg --disable-cgi"; \
    cd ~; \
    eval "$(~/.local/bin/mise activate bash)"; \
    ~/.local/bin/mise install -y -v php@8.2.30; \
'

# mise のグローバル設定ファイルの追加
if [ ! -e /home/node/.config/mise/ ]; then
    mkdir -p /home/node/.config/mise/
fi
cat << EOS > /home/node/.config/mise/config.toml 
[tools]
php = "8.2.30"

[settings]
# mise の php を使わない場合
# disable_tools = ["php"]
EOS

# xdebug, imagick インストール
if [ -e /tmp/pear ]; then sudo chown -R node /tmp/pear; else mkdir /tmp/pear; fi
/bin/bash -c '\
    cd ~; \
    eval "$(~/.local/bin/mise activate bash)"; \
    pecl channel-update pecl.php.net; \
    pecl install xdebug-3.3.2; \
    yes "" | pecl install imagick-3.8.0; \
'

# Enable PHP extensions（`php -m` で表示されない組み込まれていないものを追加指定）
/bin/bash -c '\
    eval "$(~/.local/bin/mise activate bash)"; \
    PHP_INI_DIR="/home/node/.local/share/mise/installs/php/8.2.30/conf.d"; \
    if [ ! -d "$PHP_INI_DIR" ]; then mkdir -p "$PHP_INI_DIR"; fi; \
    echo "zend_extension=opcache.so" | tee "$PHP_INI_DIR/opcache.ini"; \
    echo "zend_extension=xdebug.so" | tee "$PHP_INI_DIR/xdebug.ini"; \
    echo "extension=imagick.so" | tee "$PHP_INI_DIR/imagick.ini"; \
'

# dbgpClient インストール
sudo sh -c 'curl -O https://xdebug.org/files/binaries/dbgpClient \
&& chmod +x dbgpClient \
&& mv dbgpClient /usr/local/bin/ \
'

# WP-CLI インストール
sudo sh -c 'curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x wp-cli.phar \
&& mv wp-cli.phar /usr/local/bin/wp \
'