# 使用 Python 3.9 或更高版本
FROM python:3.9-slim
# 或者使用 Python 3.10
# FROM python:3.10-slim
# 或者使用 Python 3.11  
# FROM python:3.11-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# 复制 requirements 文件
COPY requirements.txt .

# 升级 pip 并安装依赖
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 验证 black 安装
RUN python -c "import black; print(f'Black version: {black.__version__}')"

COPY . .
RUN mkdir -p data config yaml

CMD ["python", "run.py"]
