FROM ubuntu:24.04

# 安装基础依赖
RUN apt-get update && \
    apt-get install -y \
        xorg \
        libgtk-3-0 \
        curl \
        unzip \
        zip \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安装 SDKMAN 和 Java 24
RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
             sdk install java 24.ea.31-open && \
             sdk default java 24.ea.31-open"

# 设置 Java 环境变量
ENV JAVA_HOME=/root/.sdkman/candidates/java/current
ENV PATH=$JAVA_HOME/bin:$PATH

# 下载 JavaFX 25.0.2
WORKDIR /opt
RUN wget https://download2.gluonhq.com/openjfx/25.0.2/openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    unzip openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    rm openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    mv javafx-sdk-25.0.2 javafx

ENV JAVAFX_HOME=/opt/javafx/lib

WORKDIR /jproserver
CMD ["./bin/restart.sh"]
