##
## @file        Dockerfile
## @brief       Dockerfile for JavaFX with JDK 24 using Azul Zulu FX
## @author      Adapted from Keitetsu's work
## @date        2026/02/27
##

# 使用正确的 Azul Zulu FX 24 镜像（包含 JavaFX）
FROM azul/zulu-openjdk:24-fx

LABEL maintainer="your-email@example.com"

##
## 安装系统依赖
##
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y -qq && \
    apt-get install -y -qq --no-install-recommends \
    gosu \
    sudo \
    apt-utils \
    locales \
    locales-all \
    wget \
    gzip \
    tar \
    unzip \
    x11-utils \
    libgtk-3-0 \
    libcanberra-gtk3-module \
    libpango-1.0-0 \
    libcairo2 \
    libfreetype6 \
    libfontconfig1 \
    xvfb \
    git \
    ca-certificates \
    && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/* && \
    rm -rf /var/cache/* && \
    rm -rf /var/lib/apt/lists/*

# 验证 JavaFX 已包含在 JDK 中
RUN java --list-modules | grep javafx && \
    echo "✓ JavaFX is included in this JDK" || \
    (echo "✗ JavaFX not found" && exit 1)

##
## 创建虚拟显示环境（用于无头服务器）
##
ENV DISPLAY=:99

##
## locale settings
##
RUN locale-gen en_US.UTF-8 && \
    update-locale
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

##
## ENTRYPOINT settings
##
RUN echo '#!/bin/bash\n\
# Start Xvfb virtual display if not already running\n\
if [ ! -e /tmp/.X99-lock ]; then\n\
    Xvfb :99 -screen 0 1024x768x24 &\n\
    echo "Started Xvfb on display :99"\n\
fi\n\
\n\
# Execute the command passed to docker\n\
exec "$@"' > /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

RUN mkdir -p /data /jproserver
WORKDIR /jproserver


CMD ["sh", "-c", "cd /jproserver && ./bin/restart.sh"]
