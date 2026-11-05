FROM ubuntu:26.04

ENV DEBIAN_FRONTEND noninteractive

COPY ./init /root/init

RUN sh /root/init/install_mkcert.sh
