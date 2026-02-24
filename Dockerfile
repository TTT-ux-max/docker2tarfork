FROM ubuntu:24.04

# 安装基础依赖
RUN apt-get update && \
    apt-get install -y \
        xorg \
        libgtk-3-0 \
        wget \
        curl \
        gcc \
        libz-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 下载并安装 GraalVM JDK 24
WORKDIR /opt
RUN wget https://download.oracle.com/graalvm/24/latest/graalvm-jdk-24_linux-x64_bin.tar.gz && \
    tar -xzf graalvm-jdk-24_linux-x64_bin.tar.gz && \
    rm graalvm-jdk-24_linux-x64_bin.tar.gz && \
    mv graalvm-jdk-24* graalvm

ENV JAVA_HOME=/opt/graalvm
ENV PATH=$JAVA_HOME/bin:$PATH

# 下载 JavaFX 25.0.2
RUN wget https://download2.gluonhq.com/openjfx/25.0.2/openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    unzip openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    rm openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    mv javafx-sdk-25.0.2 javafx

ENV JAVAFX_HOME=/opt/javafx/lib

WORKDIR /jproserver
CMD ["./bin/restart.sh"]
