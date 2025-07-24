FROM php:8.2-apache

ARG USER_NAME=www-data
ARG USER_UID=1000
ARG USER_GID=1000

WORKDIR /var/www/html

# apache2 で使用するモジュールを有効化
RUN a2enmod rewrite \
    && a2enmod actions

# 基本コマンドのインストール
RUN apt-get update \
    && apt-get install -y \
        libonig-dev \
        git \
        bash-completion \
        sudo

# LAMP アプリでよく使うパッケージのインストール
RUN apt-get install -y --no-install-recommends \
        ghostscript \
        less \
        ssh-client \
        mariadb-client

# PHP と PHP 用モジュールで必要なパッケージのインストール
RUN apt-get install -y --no-install-recommends \
        wget \
        unzip \
        libpq-dev \
        libxml2-dev \
		libfreetype6-dev \
		libjpeg-dev \
		libmagickwand-dev \
		libpng-dev \
		libzip-dev \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Docker で PHP のモジュールを使うためのコマンド実行
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j "$(nproc)" \
		bcmath \
		exif \
		gd \
		mysqli \
        mbstring \
		opcache \
        pdo_mysql \
        xml \
		zip

# xdebug, imagick インストール
RUN pecl install xdebug-3.3.2 \
	&& pecl install imagick-3.8.0 \
    && docker-php-ext-enable xdebug imagick xdebug

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

# Node.js のインストール
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# カスタマイズ用ファイルのコピー
COPY etc_apache2/conf-available/docker-php.conf /etc/apache2/conf-available/docker-php.conf
COPY etc_apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY usr_local_etc_php/php.ini /usr/local/etc/php/php.ini
COPY usr_local_etc_php/conf.d/opcache-recommended.ini /usr/local/etc/php/conf.d/opcache-recommended.ini
COPY usr_local_etc_php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY init-wp.sh /var/www/html/init-wp.sh
COPY html.code-workspace /var/www/html/html.code-workspace

# www-data ユーザーの調整
RUN usermod -u ${USER_UID} ${USER_NAME} \
    && groupmod -g ${USER_GID} ${USER_NAME} \
    && echo "${USER_NAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME} \
    && chmod 440 /etc/sudoers.d/${USER_NAME} \ 
    && chown -R ${USER_NAME}:${USER_NAME} /var/www \
    && chsh -s /bin/bash ${USER_NAME}
