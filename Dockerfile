# 使用基于 Debian bullseye 或 bookworm 的 Python 镜像
FROM python:3.9-slim-bullseye
# 或者使用
# FROM python:3.9-slim-bookworm

WORKDIR /app

# 安装系统依赖（修改后的包名）
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# 显示 Python 版本
RUN python --version && pip --version

COPY requirements.txt .

# 安装 Python 依赖
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

COPY . .
RUN mkdir -p data config yaml

CMD ["python", "run.py"]
