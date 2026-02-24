FROM ubuntu:24.04

# 安装基础依赖
RUN apt-get update && \
    apt-get install -y \
        libgtk-3-0 \
        libx11-6 \
        libxext6 \
        libxrender1 \
        libxtst6 \
        libxi6 \
        wget \
        curl \
        unzip \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 添加 Liberica JDK 仓库（ARM64 版本）
RUN wget -q -O /usr/share/keyrings/bellsoft.asc https://download.bell-sw.com/pki/GPG-KEY-bellsoft && \
    echo "deb [arch=arm64 signed-by=/usr/share/keyrings/bellsoft.asc] https://apt.bell-sw.com/ stable main" > /etc/apt/sources.list.d/bellsoft.list

# 安装 Liberica JDK 24 (ARM64)
RUN apt-get update && \
    apt-get install -y bellsoft-java24-full && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 下载 JavaFX 25.0.2 ARM64 版本
WORKDIR /opt
# Gluon 目前没有官方 ARM64 JavaFX SDK，需要从其他源获取或使用 Liberica 的 Full JDK
# 方法1：使用 Liberica JDK 24 Full（包含 JavaFX）
# 如果您想使用 Liberica Full JDK（已经包含 JavaFX），可以这样做：
# RUN apt-get install -y bellsoft-java24-full

# 方法2：如果确实需要单独的 JavaFX SDK，尝试从 Gluon 下载标准版（可能是 x86_64，在 ARM64 上可能不兼容）
# 或者使用其他提供 ARM64 JavaFX 的源
# 目前 Gluon 官方提供的 JavaFX SDK 主要是 x86_64 架构
# 对于 ARM64，建议使用 Liberica Full JDK，因为它已经包含 JavaFX

# 如果您坚持需要单独的 JavaFX SDK，可以尝试从其他源获取 ARM64 版本
# 例如使用 BellSoft 的 ARM64 JavaFX 模块
# 或者使用如下方法安装 OpenJFX ARM64（如果可用）
# 注意：这可能不稳定，建议使用 Liberica Full JDK

# 可选：如果您确定需要单独的 JavaFX SDK，可以尝试：
RUN wget https://download2.gluonhq.com/openjfx/25.0.2/openjfx-25.0.2_linux-aarch64_bin-sdk.zip && \
    unzip openjfx-25.0.2_linux-aarch64_bin-sdk.zip && \
    rm openjfx-25.0.2_linux-aarch64_bin-sdk.zip && \
    mv javafx-sdk-25.0.2 /opt/javafx

# 设置环境变量（根据实际安装路径调整）
ENV JAVA_HOME=/usr/lib/jvm/bellsoft-java24-full-arm64
ENV PATH=$JAVA_HOME/bin:$PATH

# 如果使用 Liberica Full JDK（包含 JavaFX），不需要单独的 JAVAFX_HOME
# 如果需要，可以设置但指向 JDK 内的 JavaFX 模块
ENV JAVAFX_HOME=$JAVA_HOME/lib

# 如果下载了独立的 JavaFX SDK，使用以下设置：
# ENV JAVAFX_HOME=/opt/javafx/lib
# ENV CLASSPATH=$JAVAFX_HOME/*:$CLASSPATH

# 创建应用目录
RUN mkdir -p /jproserver

WORKDIR /jproserver

# 创建非 root 用户
RUN useradd -m -s /bin/bash jpro && \
    chown -R jpro:jpro /jproserver

USER jpro

# 如果 restart.sh 需要执行权限
# COPY ./bin /jproserver/bin
# RUN chmod +x /jproserver/bin/restart.sh

CMD ["./bin/restart.sh"]
