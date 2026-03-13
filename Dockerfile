# 使用Python官方镜像作为基础镜像
FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN mkdir -p data  config yaml
CMD ["python","run.py"]
