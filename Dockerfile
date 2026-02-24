FROM ubuntu:24.04

# 安装基础依赖
RUN apt-get update && \
    apt-get install -y \
        xorg \
        libgtk-3-0 \
        wget \
        curl \
        unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 下载 Azul Zulu JDK 24
WORKDIR /opt
RUN wget https://cdn.azul.com/zulu/bin/zulu24.30.13-ca-jdk24.0.1-linux_x64.tar.gz && \
    tar -xzf zulu24.30.13-ca-jdk24.0.1-linux_x64.tar.gz && \
    rm zulu24.30.13-ca-jdk24.0.1-linux_x64.tar.gz && \
    mv zulu24.30.13-ca-jdk24.0.1-linux_x64 jdk-24

ENV JAVA_HOME=/opt/jdk-24
ENV PATH=$JAVA_HOME/bin:$PATH

# 下载 JavaFX 25.0.2
RUN wget https://download2.gluonhq.com/openjfx/25.0.2/openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    unzip openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    rm openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    mv javafx-sdk-25.0.2 /opt/javafx

ENV JAVAFX_HOME=/opt/javafx/lib
ENV _JAVA_OPTIONS="--module-path=/opt/javafx/lib --add-modules=ALL-MODULE-PATH"

WORKDIR /jproserver
CMD ["./bin/restart.sh"]
