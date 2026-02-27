##
## @file        Dockerfile
## @brief       Dockerfile for JavaFX with JDK 24
## @author      Adapted from Keitetsu's work
## @date        2026/02/27
## @copyright   Copyright (c) 2026
## @par         License
##              This software is released under the MIT License.
##

# 使用 JDK 24 作为基础镜像
FROM openjdk:24-slim-bookworm

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

##
## 安装 JavaFX 24 (最新稳定版)
## https://gluonhq.com/products/javafx/
## https://openjfx.io/openjfx-docs/#install-javafx
##
RUN cd /tmp && \
    # 下载 JavaFX 24 SDK (Linux x64)
    wget https://download2.gluonhq.com/openjfx/24/openjfx-24_linux-x64_bin-sdk.zip && \
    unzip openjfx-24_linux-x64_bin-sdk.zip && \
    mv javafx-sdk-24/ /usr/local/lib/ && \
    rm -rf /tmp/*

# 设置 JavaFX 环境变量
ENV PATH_TO_FX=/usr/local/lib/javafx-sdk-24/lib \
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib/javafx-sdk-24/lib

# 为了兼容性，也设置 JAVAFX_HOME
ENV JAVAFX_HOME=/usr/local/lib/javafx-sdk-24
ENV JAVA_OPTS="--module-path ${JAVAFX_HOME}/lib --add-modules javafx.controls,javafx.fxml,javafx.web,javafx.swing"

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
# 创建 entrypoint 脚本
RUN echo '#!/bin/bash\n\
# Start Xvfb virtual display if needed\n\
if [ ! -z "$DISPLAY" ] && [ ! -f /tmp/.X99-lock ]; then\n\
    Xvfb :99 -screen 0 1024x768x24 &\n\
fi\n\
\n\
# Execute the command passed to docker\n\
exec "$@"' > /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

RUN mkdir -p /data /jproserver
WORKDIR /jproserver

CMD ["sh", "-c", "cd /jproserver && ./bin/restart.sh"]
