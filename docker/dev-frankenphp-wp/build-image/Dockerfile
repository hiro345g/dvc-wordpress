FROM dunglas/frankenphp:1.12.4-php8.3-trixie

RUN install-php-extensions \
    exif \
    gd \
    intl \
    mysqli \
    opcache \
    pdo_mysql \
    sodium \
    zip

# mbstring, iconv, openssl, curl, readline, zlib, mhash, password-argon2 は公式イメージのベース PHP 8.3 にはすでに標準でコンパイル・組み込み済み

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp
# root で利用する場合は `wp --allow-root --version` のように `--allow-root` オプションをつけること

# 公式から ZIP をダウンロードして展開する。
ARG WP_VERSION=latest
RUN curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WP_VERSION}.tar.gz" \
    && tar -xzf wordpress.tar.gz -C /app \
    && rm -fr /app/public \
    && rm wordpress.tar.gz \
    && mv /app/wordpress /app/public
