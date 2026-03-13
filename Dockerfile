# 使用 Python 3.9 稳定版
FROM python:3.9-slim-bullseye

LABEL maintainer="your-email@example.com"
LABEL description="Test Automation Framework for Linux/Docker"

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    DEBIAN_FRONTEND=noninteractive \
    RUNNING_IN_DOCKER=1 \
    RUNNING_ON_LINUX=1

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    xvfb \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 显示 Python 版本
RUN python --version && pip --version

# 复制 Linux 版本的 requirements 文件
COPY requirements.txt ./requirements.txt

# 使用兼容性解析器安装依赖
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --use-deprecated=legacy-resolver -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 验证关键包安装
RUN python -c "import sys; print(f'Python version: {sys.version}')" && \
    python -c "import black; print(f'Black version: {black.__version__}')" && \
    python -c "import openai; print(f'OpenAI version: {openai.__version__}')" && \
    python -c "import cv2; print(f'OpenCV version: {cv2.__version__}')" && \
    python -c "import requests; print(f'Requests version: {requests.__version__}')" && \
    python -c "import urllib3; print(f'Urllib3 version: {urllib3.__version__}')"

# 复制应用代码
COPY . .

# 创建必要目录
RUN mkdir -p data config yaml logs reports screenshots temp

# 创建非 root 用户
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)" || exit 1

CMD ["python", "run.py"]
