#!/bin/sh

apt-get update \
    && apt-get install -y \
        libnss3-tools \
        curl \
    && rm -rf /var/lib/apt/lists/*

curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64

if [ "$(id -u)" = "0" ]; then
    cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert
    rm mkcert-v*-linux-amd64
else
    sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert
    sudo rm mkcert-v*-linux-amd64
fi
