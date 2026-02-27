FROM ubuntu:24.04

RUN apt-get update

# Install xorg and libgtk-3-0 needed to run JPro applications
RUN apt-get install -y xorg libgtk-3-0

# Install wget and software-properties-common need to add Adoptium APT repository
RUN apt-get install -y wget software-properties-common unzip tree

# Add the Adoptium (Eclipse Temurin) APT repository and import the GPG key
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://packages.adoptium.net/artifactory/deb/

# Install Temurin 24 JDK
RUN apt-get update && \
    apt-get install -y temurin-24-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 下载 JavaFX 25.0.2 AMD64 SDK
RUN wget https://download2.gluonhq.com/openjfx/25.0.2/openjfx-25.0.2_linux-x64_bin-sdk.zip && \
    unzip openjfx-25.0.2_linux-x64_bin-sdk.zip -d /opt/ && \
    rm openjfx-25.0.2_linux-x64_bin-sdk.zip

# 创建 JavaFX 符号链接
RUN ln -s /opt/javafx-sdk-25.0.2 /opt/javafx

# 调试版本的 entrypoint 脚本
RUN echo '#!/bin/bash\n\
echo "=========================================="\n\
echo "JPro AMD64 Docker Container Started (JDK 24) - DEBUG MODE"\n\
echo "=========================================="\n\
\n\
echo "=== System Information ==="\n\
echo "uname -m: $(uname -m)"\n\
echo "OSTYPE: $OSTYPE"\n\
echo "Java version:"\n\
java -version\n\
echo ""\n\
\n\
echo "=== JavaFX Installation ==="\n\
echo "JavaFX installed at: /opt/javafx"\n\
ls -la /opt/javafx/\n\
echo ""\n\
echo "JavaFX lib directory:"\n\
ls -la /opt/javafx/lib/ | head -20\n\
echo ""\n\
\n\
echo "=== Looking for JPro application ==="\n\
if [ -d "/jproserver" ]; then\n\
    echo "JPro directory found at /jproserver"\n\
    echo "Contents of /jproserver:"\n\
    ls -la /jproserver\n\
    echo ""\n\
    \n\
    echo "=== Creating JavaFX symlink ==="\n\
    # 确保目录存在\n\
    mkdir -p /jproserver/jfx\n\
    echo "Created /jproserver/jfx directory"\n\
    \n\
    # 检查 JavaFX 源目录是否存在\n\
    if [ -d "/opt/javafx/lib" ]; then\n\
        echo "JavaFX source directory exists: /opt/javafx/lib"\n\
        \n\
        # 创建符号链接\n\
        ln -sf /opt/javafx/lib /jproserver/jfx/linux\n\
        echo "Created symlink: /jproserver/jfx/linux -> /opt/javafx/lib"\n\
        \n\
        # 验证符号链接\n\
        echo "Verifying symlink:"\n\
        ls -la /jproserver/jfx/\n\
        echo ""\n\
        echo "Contents of /jproserver/jfx/linux:"\n\
        ls -la /jproserver/jfx/linux/ | head -10\n\
        \n\
        # 检查是否包含预期的 .jar 文件\n\
        echo ""\n\
        echo "Checking for JavaFX jar files:"\n\
        find /jproserver/jfx/linux -name "*.jar" | head -5\n\
    else\n\
        echo "ERROR: /opt/javafx/lib does not exist!"\n\
        exit 1\n\
    fi\n\
    \n\
    echo ""\n\
    echo "=== Starting JPro Application ==="\n\
    \n\
    # 查找启动脚本\n\
    if [ -f "/jproserver/bin/restart.sh" ]; then\n\
        echo "Found restart.sh, checking its contents:"\n\
        head -20 /jproserver/bin/restart.sh\n\
        echo ""\n\
        echo "Executing restart.sh..."\n\
        cd /jproserver\n\
        # 设置 JavaFX 环境变量\n\
        export JAVAFX_HOME=/opt/javafx\n\
        export JAVA_OPTS="$JAVA_OPTS --module-path=/opt/javafx/lib --add-modules=javafx.controls,javafx.fxml,javafx.web,javafx.media"\n\
        # 以调试模式执行\n\
        bash -x /jproserver/bin/restart.sh\n\
    elif [ -f "/jproserver/bin/start.sh" ]; then\n\
        echo "Found start.sh, checking its contents:"\n\
        head -20 /jproserver/bin/start.sh\n\
        echo ""\n\
        echo "Executing start.sh with debug..."\n\
        cd /jproserver\n\
        export JAVAFX_HOME=/opt/javafx\n\
        export JAVA_OPTS="$JAVA_OPTS --module-path=/opt/javafx/lib --add-modules=javafx.controls,javafx.fxml,javafx.web,javafx.media"\n\
        # 以调试模式执行\n\
        bash -x /jproserver/bin/start.sh\n\
    else\n\
        echo "No startup script found in /jproserver/bin/"\n\
        echo "Contents of /jproserver:"\n\
        ls -la /jproserver\n\
        echo "Contents of /jproserver/bin (if exists):"\n\
        ls -la /jproserver/bin 2>/dev/null || echo "bin directory not found"\n\
    fi\n\
else\n\
    echo "ERROR: JPro directory /jproserver not found!"\n\
    echo "Please mount your JPro application to /jproserver"\n\
    echo "Example: docker run -v /path/to/your/jproserver:/jproserver ..."\n\
fi\n\
\n\
echo ""\n\
echo "=== Container will stay alive for debugging ==="\n\
tail -f /dev/null\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

WORKDIR /
ENTRYPOINT ["/entrypoint.sh"]
