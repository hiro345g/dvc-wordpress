FROM httpd:2.4.68-trixie

COPY ./conf/httpd-ssl.conf /usr/local/apache2/conf/extra/httpd-ssl.conf
COPY ./conf/certs/server.crt /usr/local/apache2/conf/server.crt
COPY ./conf/certs/server.key /usr/local/apache2/conf/server.key

RUN sed -i \
    -e 's/^#\(LoadModule .*mod_headers.so\)/\1/' \
    -e 's/^#\(LoadModule .*mod_proxy.so\)/\1/' \
    -e 's/^#\(LoadModule .*mod_proxy_http.so\)/\1/' \
    -e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
    -e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
    -e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
    /usr/local/apache2/conf/httpd.conf
