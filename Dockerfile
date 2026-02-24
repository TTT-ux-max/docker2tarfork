FROM ubuntu:24.04

# 安装基础依赖
RUN apt-get update && \
    apt-get install -y \
        xorg \
        libgtk-3-0 \
        wget \
        unzip \
        curl \
        software-properties-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安装 Java 24 (使用 Oracle JDK 24 早期访问版本)
WORKDIR /opt
RUN wget https://download.oracle.com/java/24/latest/jdk-24_linux-x64_bin.tar.gz && \
    tar -xzf jdk-24_linux-x64_bin.tar.gz && \
    rm jdk-24_linux-x64_bin.tar.gz && \
    mv jdk-24* jdk-24

# 设置 Java 环境变量
ENV JAVA_HOME=/opt/jdk-24
ENV PATH=$JAVA_HOME/bin:$PATH

# 下载并安装 JavaFX 25.0.2
WORKDIR /opt/javafx
RUN wget https://download2.gluonhq.com/openjfx/25.0.2/openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    unzip openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    rm openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    mv javafx-sdk-25.0.2 lib

# 设置 JavaFX 环境变量
ENV JAVAFX_HOME=/opt/javafx/lib
ENV JAVAFX_MODULES=javafx.controls,javafx.fxml,javafx.web,javafx.media,javafx.swing
ENV _JAVA_OPTIONS="--module-path=/opt/javafx/lib/lib --add-modules=ALL-MODULE-PATH"

# 验证安装
RUN java -version && \
    ls -la /opt/javafx/lib/lib

# 创建工作目录
WORKDIR /jproserver

# 复制应用文件（将在 docker-compose 中挂载）
# ADD . .

# 启动命令
CMD ["./bin/restart.sh"]
