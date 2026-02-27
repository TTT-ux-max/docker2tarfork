# 使用 Liberica JDK（包含 JavaFX）
FROM bellsoft/liberica-openjdk-debian:24

# 安装依赖（注意：这是基于 Debian 的）
RUN apt-get update && apt-get install -y \
    libpango1.0-0 \
    libcairo2 \
    libfreetype6 \
    libfontconfig1 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /jproserver

# Liberica JDK 已经包含了 JavaFX，无需额外配置
ENV JAVA_OPTS=""

CMD ["sh", "-c", "cd /jproserver && ./bin/restart.sh"]
