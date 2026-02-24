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

# 下载并安装 Liberica JDK 24 (包含 JavaFX)
WORKDIR /opt
RUN wget https://download.bell-sw.com/java/24+39/bellsoft-jdk24+39-linux-amd64-full.tar.gz && \
    tar -xzf bellsoft-jdk24+39-linux-amd64-full.tar.gz && \
    rm bellsoft-jdk24+39-linux-amd64-full.tar.gz && \
    mv jdk-24* jdk-24

# 设置 Java 环境变量
ENV JAVA_HOME=/opt/jdk-24
ENV PATH=$JAVA_HOME/bin:$PATH

# 验证安装
RUN java -version

WORKDIR /jproserver
CMD ["./bin/restart.sh"]
