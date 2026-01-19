# 使用Python 3.12官方镜像
FROM python:3.12-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    supervisor \
    procps \
    && rm -rf /var/lib/apt/lists/*



# 复制应用代码
COPY app/ ./app/

# 复制supervisor配置
COPY supervisor/ /etc/supervisor/conf.d/

# 复制入口脚本
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# 创建日志目录
RUN mkdir -p /var/log/supervisor

# 暴露端口（根据您的应用调整）
EXPOSE 8000

# 设置入口点
ENTRYPOINT ["./entrypoint.sh"]
