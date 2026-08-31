FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        unzip \
        xz-utils \
        zip \
        libglu1-mesa \
        python3 \
        python3-pip \
        python3.12-venv \
        build-essential \
        clang \
        cmake \
        ninja-build \
        pkg-config \
        libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

# Flutter SDK (stable channel)
RUN git clone --depth 1 -b stable https://github.com/flutter/flutter.git /opt/flutter \
    && chown -R ubuntu:ubuntu /opt/flutter

USER ubuntu
WORKDIR /home/ubuntu

RUN /opt/flutter/bin/flutter config --enable-web --no-analytics \
    && /opt/flutter/bin/flutter precache --web

ENV PATH="/opt/flutter/bin:${PATH}"
