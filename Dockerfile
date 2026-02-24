FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y \
        xorg \
        libgtk-3-0 \
        wget \
        curl \
        gnupg \
        software-properties-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 添加 Eclipse Temurin 仓库
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://packages.adoptium.net/artifactory/deb/

# 安装 JDK 24（如果仓库中有）
RUN apt-get update && \
    apt-get install -y temurin-24-jdk || \
    apt-get install -y temurin-21-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 下载 JavaFX 25.0.2
WORKDIR /opt
RUN wget https://download2.gluonhq.com/openjfx/25.0.2/openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    unzip openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    rm openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    mv javafx-sdk-25.0.2 javafx

ENV JAVAFX_HOME=/opt/javafx/lib
ENV _JAVA_OPTIONS="--module-path=/opt/javafx/lib/lib --add-modules=ALL-MODULE-PATH"

WORKDIR /jproserver
CMD ["./bin/restart.sh"]
