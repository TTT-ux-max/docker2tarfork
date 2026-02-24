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

# 安装 Java 24 (Liberica JDK)
WORKDIR /opt
RUN wget https://download.bell-sw.com/java/24+39/bellsoft-jdk24+39-linux-amd64.tar.gz && \
    tar -xzf bellsoft-jdk24+39-linux-amd64.tar.gz && \
    rm bellsoft-jdk24+39-linux-amd64.tar.gz && \
    mv jdk-24* jdk-24

ENV JAVA_HOME=/opt/jdk-24
ENV PATH=$JAVA_HOME/bin:$PATH

# 下载 JavaFX 25.0.2 SDK
RUN wget https://download2.gluonhq.com/openjfx/25.0.2/openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    unzip openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    rm openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    mv javafx-sdk-25.0.2 /opt/javafx

ENV JAVAFX_HOME=/opt/javafx/lib
ENV JAVAFX_MODULES=javafx.controls,javafx.fxml,javafx.web,javafx.media,javafx.swing
ENV _JAVA_OPTIONS="--module-path=/opt/javafx/lib --add-modules=ALL-MODULE-PATH"

# 验证安装
RUN java -version && \
    ls -la /opt/javafx/lib

WORKDIR /jproserver
CMD ["./bin/restart.sh"]
