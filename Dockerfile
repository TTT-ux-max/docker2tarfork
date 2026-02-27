FROM bellsoft/liberica-openjdk-debian:24

# 安装基础依赖
RUN apt-get update && apt-get install -y \
    libpango1.0-0 \
    libcairo2 \
    libfreetype6 \
    libfontconfig1 \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# 验证 JavaFX 是否存在
RUN java --list-modules | grep javafx || echo "JavaFX modules not found"

WORKDIR /jproserver

# 设置 DISPLAY 环境变量（如果需要）
ENV DISPLAY=:99

# 如果需要虚拟显示
CMD Xvfb :99 -screen 0 1024x768x24 & ./bin/restart.sh
