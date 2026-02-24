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

# 添加 Liberica JDK 仓库
RUN wget -q -O - https://download.bell-sw.com/pki/GPG-KEY-bellsoft | apt-key add - && \
    echo "deb [arch=amd64] https://apt.bell-sw.com/ stable main" > /etc/apt/sources.list.d/bellsoft.list

# 安装 Liberica JDK 24
RUN apt-get update && \
    apt-get install -y bellsoft-java24-full && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 下载 JavaFX 25.0.2（如果需要额外模块）
WORKDIR /opt
RUN wget https://download2.gluonhq.com/openjfx/25.0.2/openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    unzip openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    rm openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    mv javafx-sdk-25.0.2 /opt/javafx

# 设置环境变量
ENV JAVA_HOME=/usr/lib/jvm/bellsoft-java24-full-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
ENV JAVAFX_HOME=/opt/javafx/lib

WORKDIR /jproserver
CMD ["./bin/restart.sh"]
