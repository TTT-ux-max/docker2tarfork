FROM azul/zulu-openjdk:24-fx

# 安装必要的图形库和工具
RUN apt-get update && apt-get install -y \
    libpango1.0-0 \
    libcairo2 \
    libfreetype6 \
    libfontconfig1 \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# 验证JavaFX是否存在 (可选)
RUN java --list-modules | grep javafx

WORKDIR /jproserver
ENV DISPLAY=:99
# 无需再设置 --module-path, 因为JavaFX已在JDK中

CMD ["sh", "-c", "cd /jproserver && ./bin/restart.sh"]
