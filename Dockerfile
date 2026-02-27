##
## @file        Dockerfile
## @brief       Dockerfile for JavaFX with JDK 24
## @author      Adapted from Keitetsu's work
## @date        2026/02/27
##

# 使用标准的 Debian 镜像 + 手动安装 JDK 24 和 JavaFX 24
FROM debian:bookworm-slim

LABEL maintainer="your-email@example.com"

##
## 安装系统依赖和 JDK 24
##
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y -qq && \
    apt-get install -y -qq --no-install-recommends \
    wget \
    gnupg \
    ca-certificates \
    gosu \
    sudo \
    apt-utils \
    locales \
    locales-all \
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
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

##
## 安装 JDK 24 (使用 Eclipse Temurin 构建)
##
RUN wget -O /tmp/jdk.tar.gz https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24%2B36/OpenJDK24U-jdk_x64_linux_hotspot_24_36.tar.gz && \
    tar -xzf /tmp/jdk.tar.gz -C /opt/ && \
    mv /opt/jdk-24+36 /opt/jdk-24 && \
    rm /tmp/jdk.tar.gz

ENV JAVA_HOME=/opt/jdk-24
ENV PATH=$JAVA_HOME/bin:$PATH

##
## 安装 JavaFX 24
##
RUN cd /tmp && \
    wget https://download2.gluonhq.com/openjfx/24/openjfx-24_linux-x64_bin-sdk.zip && \
    unzip openjfx-24_linux-x64_bin-sdk.zip && \
    mv javafx-sdk-24/ /opt/ && \
    rm -rf /tmp/*

ENV JAVAFX_HOME=/opt/javafx-sdk-24
ENV JAVA_OPTS="--module-path ${JAVAFX_HOME}/lib --add-modules javafx.controls,javafx.fxml,javafx.web"

##
## 验证 Java 和 JavaFX 安装
##
RUN java -version && \
    ls -la ${JAVAFX_HOME}/lib && \
    echo "JavaFX modules:" && \
    java --module-path ${JAVAFX_HOME}/lib --list-modules | grep javafx

##
## 创建虚拟显示环境
##
ENV DISPLAY=:99

##
## locale settings
##
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

##
## ENTRYPOINT settings
##
RUN echo '#!/bin/bash\n\
# Start Xvfb virtual display\n\
if [ ! -e /tmp/.X99-lock ]; then\n\
    Xvfb :99 -screen 0 1024x768x24 &\n\
    echo "Started Xvfb on display :99"\n\
fi\n\
\n\
# Execute command\n\
exec "$@"' > /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

RUN mkdir -p /data /jproserver
WORKDIR /jproserver



CMD ["sh", "-c", "cd /jproserver && ./bin/restart.sh"]
