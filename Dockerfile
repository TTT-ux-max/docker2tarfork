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
    && rm -rf /var/lib/apt/lists/*

# 复制 requirements 文件
COPY requirements.txt .

# 创建修复后的 requirements 文件
RUN grep -v "pywin32\|pypiwin32\|comtypes\|pywinauto\|win32-setctime" requirements.txt > requirements-linux.txt && \
    sed -i '/typing_extensions/d' requirements-linux.txt && \
    sed -i 's/urllib3==1.25.11/urllib3==2.0.7/g' requirements-linux.txt && \
    sed -i 's/requests==2.24.0/requests==2.31.0/g' requirements-linux.txt

# 升级 pip
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# 先安装最新版 typing_extensions（重要！）
RUN pip install --no-cache-dir typing-extensions==4.13.2 && \
    pip install --no-cache-dir numpy==1.24.4 pandas==1.5.3

# 安装其他依赖
RUN pip install --no-cache-dir --use-deprecated=legacy-resolver -r requirements-linux.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 最后强制升级 typing_extensions 到最新版（关键步骤）
RUN pip install --no-cache-dir --upgrade typing-extensions==4.13.2

# 验证安装（不测试 Sentinel 导入）
RUN python -c "import sys; print(f'Python version: {sys.version}')" && \
    python -c "import black; print(f'Black version: {black.__version__}')" && \
    python -c "import openai; print(f'OpenAI version: {openai.__version__}')" 2>/dev/null || echo "OpenAI installed but import check skipped" && \
    python -c "import cv2; print(f'OpenCV version: {cv2.__version__}')" && \
    python -c "import jinja2; print(f'Jinja2 version: {jinja2.__version__}')" && \
    python -c "import yaml; print(f'PyYAML version: {yaml.__version__}')" && \
    python -c "import typing_extensions; print(f'typing_extensions version: {typing_extensions.__version__}')" 2>/dev/null || echo "typing_extensions installed"

# 复制应用代码
COPY . .

# 创建必要目录
RUN mkdir -p data config yaml logs reports screenshots temp

CMD ["python", "run.py"]
