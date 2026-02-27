FROM ubuntu:24.04

RUN apt-get update

# Install xorg and libgtk-3-0 needed to run JPro applications
RUN apt-get install -y xorg libgtk-3-0

# Install wget and software-properties-common need to add Adoptium APT repository
RUN apt-get install -y wget software-properties-common unzip

# Add the Adoptium (Eclipse Temurin) APT repository and import the GPG key
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://packages.adoptium.net/artifactory/deb/

# Install Temurin 24 JDK
RUN apt-get update && \
    apt-get install -y temurin-24-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 创建符号链接来模拟 BellSoft JDK 路径（解决硬编码路径问题）
RUN mkdir -p /usr/lib/jvm && \
    ln -sf /usr/lib/jvm/temurin-24-jdk-amd64 /usr/lib/jvm/bellsoft-x86_64

# 下载 JavaFX 25.0.2 AMD64 SDK
RUN wget https://download2.gluonhq.com/openjfx/25.0.2/openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    unzip openjfx-25.0.2_linux-x64_bin-sdk.zip -d /opt/ && \
    rm openjfx-25.0.2_linux-x64_bin-sdk.zip

# 创建 JavaFX 符号链接
RUN ln -s /opt/javafx-sdk-25.0.2 /opt/javafx

# 设置 JavaFX 环境变量
ENV JAVAFX_HOME=/opt/javafx
ENV JAVAFX_LIB_PATH=$JAVAFX_HOME/lib

# 创建启动脚本
RUN echo '#!/bin/bash\n\
echo "=========================================="\n\
echo "JPro AMD64 Docker Container Started (JDK 24)"\n\
echo "=========================================="\n\
\n\
# 设置 Java 环境变量\n\
export JAVA_HOME=/usr/lib/jvm/temurin-24-jdk-amd64\n\
export PATH=$JAVA_HOME/bin:$PATH\n\
\n\
echo "Java version:"\n\
java -version\n\
echo "JAVA_HOME: $JAVA_HOME"\n\
echo ""\n\
\n\
# 验证 BellSoft 符号链接\n\
if [ -L "/usr/lib/jvm/bellsoft-x86_64" ]; then\n\
    echo "BellSoft JDK symlink exists: $(ls -la /usr/lib/jvm/bellsoft-x86_64)"\n\
else\n\
    echo "Creating BellSoft JDK symlink..."\n\
    ln -sf /usr/lib/jvm/temurin-24-jdk-amd64 /usr/lib/jvm/bellsoft-x86_64\n\
fi\n\
\n\
echo "JavaFX libraries available at: /opt/javafx/lib"\n\
ls -la /opt/javafx/lib/ | head -10\n\
echo ""\n\
\n\
# 检查 JPro 应用\n\
if [ -d "/jproserver" ]; then\n\
    echo "JPro directory found at /jproserver"\n\
    \n\
    # 创建 JavaFX 符号链接\n\
    mkdir -p /jproserver/jfx\n\
    \n\
    if [ ! -d "/jproserver/jfx/linux" ]; then\n\
        echo "Creating JavaFX symlink for JPro application..."\n\
        ln -sf /opt/javafx/lib /jproserver/jfx/linux\n\
        echo "Symlink created: /jproserver/jfx/linux -> /opt/javafx/lib"\n\
    fi\n\
    \n\
    # 验证 JavaFX 链接\n\
    if [ -d "/jproserver/jfx/linux" ]; then\n\
        echo "JavaFX symlink verified. Contents:"\n\
        ls -la /jproserver/jfx/linux/ | head -5\n\
    else\n\
        echo "ERROR: JavaFX symlink creation failed!"\n\
    fi\n\
    \n\
    # 检查并启动应用\n\
    if [ -f "/jproserver/bin/restart.sh" ]; then\n\
        echo "Found restart.sh, executing..."\n\
        cd /jproserver\n\
        # 传递 JavaFX 模块参数\n\
        export JAVA_OPTS="$JAVA_OPTS --module-path=/opt/javafx/lib --add-modules=javafx.controls,javafx.fxml,javafx.web,javafx.media"\n\
        echo "Executing: /jproserver/bin/restart.sh"\n\
        exec /jproserver/bin/restart.sh\n\
    elif [ -f "/jproserver/bin/start.sh" ]; then\n\
        echo "Found start.sh, executing..."\n\
        cd /jproserver\n\
        export JAVA_OPTS="$JAVA_OPTS --module-path=/opt/javafx/lib --add-modules=javafx.controls,javafx.fxml,javafx.web,javafx.media"\n\
        echo "Executing: /jproserver/bin/start.sh"\n\
        exec /jproserver/bin/start.sh\n\
    else\n\
        echo "No startup script found in /jproserver/bin/"\n\
        echo "Contents of /jproserver:"\n\
        ls -la /jproserver\n\
    fi\n\
else\n\
    echo "ERROR: JPro directory /jproserver not found!"\n\
    echo "Please mount your JPro application to /jproserver"\n\
    echo "Example: docker run -v /path/to/your/jproserver:/jproserver ..."\n\
fi\n\
\n\
# 保持容器运行\n\
echo ""\n\
echo "Container will stay alive for debugging. Press Ctrl+C to exit."\n\
tail -f /dev/null\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

WORKDIR /
ENTRYPOINT ["/entrypoint.sh"]
