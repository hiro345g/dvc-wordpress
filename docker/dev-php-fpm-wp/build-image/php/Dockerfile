FROM php:8.3-fpm-trixie

WORKDIR /var/www/html

# 1つめの apt-get install: 基本コマンドのインストール
# 2つめの apt-get install: LAMP アプリでよく使うパッケージのインストール
# 3つめの apt-get install: PHP と PHP 用モジュールで必要なパッケージのインストール
RUN apt-get update \
    && apt-get install -y \
        libonig-dev \
        git \
        bash-completion \
        sudo \
        msmtp \
        ca-certificates\
    && apt-get install -y --no-install-recommends \
        ghostscript \
        less \
        ssh-client \
        mariadb-client \
    && apt-get install -y --no-install-recommends \
        wget \
        unzip \
		libfreetype6-dev \
        libicu-dev \
		libjpeg-dev \
		libmagickwand-dev \
		libpng-dev \
        libpq-dev \
        libxml2-dev \
		libzip-dev \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Docker で PHP のモジュールを使うためのコマンド実行
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j "$(nproc)" \
		bcmath \
		exif \
		gd \
        intl\
        mbstring \
		mysqli \
		opcache \
        pdo_mysql \
        xml \
		zip

# xdebug, imagick インストール
RUN pecl install xdebug-3.3.2 \
	&& pecl install imagick-3.8.0 \
    && docker-php-ext-enable xdebug imagick

# dbgpClient インストール
RUN curl -O https://xdebug.org/files/binaries/dbgpClient \
    && chmod +x dbgpClient \
    && mv dbgpClient /usr/local/bin/

# Composer インストール
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer

# WP-CLI インストール
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp
# root で利用する場合は `wp --allow-root --version` のように `--allow-root` オプションをつけること

# カスタマイズ用ファイルのコピー
# COPY usr_local_etc_php/php.ini /usr/local/etc/php/php.ini
COPY usr_local_etc_php/conf.d/opcache-recommended.ini /usr/local/etc/php/conf.d/opcache-recommended.ini
COPY usr_local_etc_php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# 公式から ZIP をダウンロードして展開する。
ARG WP_VERSION=latest
RUN curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WP_VERSION}.tar.gz" \
    && tar -xzf wordpress.tar.gz -C /var/www/ \
    && rm wordpress.tar.gz \
    && rm -fr /var/www/html \
    && mv /var/www/wordpress /var/www/html \
    && chown -R www-data:www-data /var/www/html
