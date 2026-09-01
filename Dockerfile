# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-ubuntu:resolute

# set labels
ARG BUILD_DATE
LABEL maintainer="upwindcore"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.title="OpenSSH Server"
LABEL org.opencontainers.image.description="Containerized OpenSSH Server"
LABEL org.opencontainers.image.source="https://github.com/upwindcore/docker-openssh-server"
LABEL org.opencontainers.image.licenses="GPL-3.0-only"

# environment settings
ENV LSIO_FIRST_PARTY=false
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y \
    logrotate \
    nano \
    netcat-openbsd \
    sudo && \
  echo "**** install openssh-server ****" && \
  apt-get install -y \
    openssh-client \
    openssh-sftp-server && \
  echo "**** setup openssh environment ****" && \
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
  usermod --shell /bin/bash abc && \
  echo "**** clean up ****" && \
  apt-get clean && \
  rm -rf \
    $HOME/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

EXPOSE 2222

VOLUME /config
