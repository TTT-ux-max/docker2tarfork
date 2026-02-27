# 修正：使用 -full 标签获取包含 JavaFX 的完整版本
FROM bellsoft/liberica-openjdk-debian:24-full

# 安装基础依赖
RUN apt-get update && apt-get install -y \
    libpango1.0-0 \
    libcairo2 \
    libfreetype6 \
    libfontconfig1 \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# 验证 JavaFX 是否已包含
RUN java --list-modules | grep javafx && echo "JavaFX modules found successfully"

WORKDIR /jproserver

ENV DISPLAY=:99

CMD Xvfb :99 -screen 0 1024x768x24 & ./bin/restart.sh
