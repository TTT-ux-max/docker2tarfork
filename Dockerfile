# 修改符号链接部分，使用 JPro 期望的平台名称
RUN ln -s /opt/javafx-sdk-25.0.2 /opt/javafx

# 修改 entrypoint 脚本中的符号链接创建部分
RUN echo '#!/bin/bash\n\
echo "=========================================="\n\
echo "JPro AMD64 Docker Container Started (JDK 24)"\n\
echo "=========================================="\n\
echo "Java version:"\n\
java -version\n\
echo ""\n\
echo "JavaFX AMD64 libraries available at: /opt/javafx/lib"\n\
ls -la /opt/javafx/lib/ | head -10\n\
echo ""\n\
echo "Looking for JPro application at /jproserver..."\n\
\n\
# 检查 JPro 应用是否已挂载\n\
if [ -d "/jproserver" ]; then\n\
    echo "JPro directory found."\n\
    \n\
    # JPro 可能期望的平台名称是 "linux" 而不是 "linux-x64"\n\
    # 尝试多种可能的路径\n\
    if [ ! -d "/jproserver/jfx/linux" ]; then\n\
        echo "Creating JavaFX symlink for JPro application (linux)..."\n\
        mkdir -p /jproserver/jfx\n\
        ln -sf /opt/javafx/lib /jproserver/jfx/linux\n\
    fi\n\
    \n\
    # 同时也创建 linux-x64 作为备选\n\
    if [ ! -d "/jproserver/jfx/linux-x64" ]; then\n\
        echo "Creating JavaFX symlink for JPro application (linux-x64)..."\n\
        mkdir -p /jproserver/jfx\n\
        ln -sf /opt/javafx/lib /jproserver/jfx/linux-x64\n\
    fi\n\
    \n\
    # 查找启动脚本\n\
    if [ -f "/jproserver/bin/restart.sh" ]; then\n\
        echo "Found restart.sh, executing..."\n\
        cd /jproserver\n\
        # 设置 JavaFX 环境变量\n\
        export JAVAFX_HOME=/opt/javafx\n\
        exec /jproserver/bin/restart.sh\n\
    elif [ -f "/jproserver/bin/start.sh" ]; then\n\
        echo "Found start.sh, executing..."\n\
        cd /jproserver\n\
        # 设置 JavaFX 环境变量\n\
        export JAVAFX_HOME=/opt/javafx\n\
        exec /jproserver/bin/start.sh\n\
    else\n\
        echo "No startup script found in /jproserver/bin/"\n\
        echo "Contents of /jproserver:"\n\
        ls -la /jproserver\n\
        echo "Contents of /jproserver/bin (if exists):"\n\
        ls -la /jproserver/bin 2>/dev/null || echo "bin directory not found"\n\
    fi\n\
else\n\
    echo "JPro directory /jproserver not found!"\n\
    echo "Please mount your JPro application to /jproserver"\n\
    echo "Example: docker run -v /path/to/your/jproserver:/jproserver ..."\n\
fi\n\
\n\
# 保持容器运行（便于调试）\n\
echo ""\n\
echo "Container will stay alive for debugging. Press Ctrl+C to exit."\n\
tail -f /dev/null\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh
