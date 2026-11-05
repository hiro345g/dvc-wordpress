# ../../phpa-apache/build-image/build.sh でイメージ作成後
FROM dvc-wordpress:php-apache-202611

# カスタマイズ用ファイルのコピー
COPY ./etc/ssl /etc/ssl
COPY ./etc/apache2/sites-available/001-ssl.conf /etc/apache2/sites-available/001-ssl.conf

# www-data ユーザーの調整
RUN a2enmod ssl && a2ensite 001-ssl
RUN chown -R www-data:www-data /etc/ssl/certs /etc/ssl/private
RUN chmod 600 /etc/ssl/private/site.key
