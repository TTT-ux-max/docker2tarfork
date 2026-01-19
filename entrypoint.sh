#!/bin/bash

# 启动supervisord守护进程
echo "Starting supervisord..."
exec supervisord -n -c /etc/supervisor/supervisord.conf
