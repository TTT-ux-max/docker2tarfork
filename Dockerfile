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

# 复制 requirements 文件
COPY requirements.txt .

# 创建修复后的 requirements 文件
RUN grep -v "pywin32\|pypiwin32\|comtypes\|pywinauto\|win32-setctime" requirements.txt > requirements-linux.txt && \
    # 更新 typing_extensions 到最新版
    sed -i '/typing_extensions/d' requirements-linux.txt && \
    # 更新 urllib3 到兼容版本
    sed -i 's/urllib3==1.25.11/urllib3==2.0.7/g' requirements-linux.txt && \
    # 更新 requests 到兼容版本
    sed -i 's/requests==2.24.0/requests==2.31.0/g' requirements-linux.txt && \
    # 更新 PyYAML 到兼容版本
    sed -i 's/PyYAML==5.3.1/PyYAML==6.0.1/g' requirements-linux.txt && \
    # 更新 Jinja2 到兼容版本
    sed -i 's/Jinja2==3.0.3/Jinja2==3.1.3/g' requirements-linux.txt

# 先安装基础包
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir typing-extensions==4.12.2 && \
    pip install --no-cache-dir numpy==1.24.4 pandas==1.5.3

# 然后安装其他依赖
RUN pip install --no-cache-dir -r requirements-linux.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 最后升级 typing_extensions 到最新版
RUN pip install --no-cache-dir --upgrade typing-extensions==4.13.2

# 验证关键包安装
RUN python -c "import sys; print(f'Python version: {sys.version}')" && \
    python -c "import black; print(f'Black version: {black.__version__}')" && \
    python -c "import openai; print(f'OpenAI version: {openai.__version__}')" && \
    python -c "import cv2; print(f'OpenCV version: {cv2.__version__}')" && \
    python -c "import requests; print(f'Requests version: {requests.__version__}')" && \
    python -c "import urllib3; print(f'Urllib3 version: {urllib3.__version__}')" && \
    python -c "import typing_extensions; print(f'Typing Extensions version: {typing_extensions.__version__}')"

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
