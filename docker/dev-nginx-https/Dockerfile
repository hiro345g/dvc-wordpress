FROM nginx:1.31.2-trixie

COPY ./docker/nginx/nginx_reverse_proxy.conf /tmp/nginx-https.conf
COPY ./docker/mkcert/backup/mkcert-keys/certs/www.dev.internal.pem /tmp/cert.pem
COPY ./docker/mkcert/backup/mkcert-keys/private/www.dev.internal.key /tmp/key.pem

ENTRYPOINT [ "nginx", "-c", "/tmp/nginx-https.conf", "-g", "daemon off;" ]
