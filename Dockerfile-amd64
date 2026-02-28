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

# 创建 BellSoft JDK 兼容的目录结构（匹配实际的 BellSoft 路径格式）
RUN mkdir -p /usr/lib/jvm/jdk-24.0.2-bellsoft-x86_64/bin && \
    ln -sf /usr/lib/jvm/temurin-24-jdk-amd64/bin/java /usr/lib/jvm/jdk-24.0.2-bellsoft-x86_64/bin/java && \
    ln -sf /usr/lib/jvm/temurin-24-jdk-amd64/bin/javac /usr/lib/jvm/jdk-24.0.2-bellsoft-x86_64/bin/javac && \
    ln -sf /usr/lib/jvm/temurin-24-jdk-amd64/bin/jshell /usr/lib/jvm/jdk-24.0.2-bellsoft-x86_64/bin/jshell 2>/dev/null || true && \
    # 验证链接创建成功
    echo "BellSoft compatibility links created:" && \
    ls -la /usr/lib/jvm/jdk-24.0.2-bellsoft-x86_64/bin/

# 同时创建通用的 bellsoft-x86_64 链接作为备选
RUN ln -sf /usr/lib/jvm/jdk-24.0.2-bellsoft-x86_64 /usr/lib/jvm/bellsoft-x86_64 2>/dev/null || true

# 下载 JavaFX 24.0.2 AMD64 SDK（使用 GluonHQ 链接）
RUN wget https://download2.gluonhq.com/openjfx/24.0.2/openjfx-24.0.2_linux-x64_bin-sdk.zip && \
    unzip openjfx-24.0.2_linux-x64_bin-sdk.zip -d /opt/ && \
    rm openjfx-24.0.2_linux-x64_bin-sdk.zip

# 创建 JavaFX 符号链接，方便引用
RUN ln -s /opt/javafx-sdk-25.0.2 /opt/javafx

# 设置 JavaFX 环境变量
ENV JAVAFX_HOME=/opt/javafx
ENV JAVAFX_LIB_PATH=$JAVAFX_HOME/lib
ENV JAVAFX_MODULES="--module-path=$JAVAFX_HOME/lib --add-modules=javafx.controls,javafx.fxml,javafx.web,javafx.media"

# 创建一个包装脚本，它会在容器启动时运行
RUN echo '#!/bin/bash\n\
echo "=========================================="\n\
echo "JPro AMD64 Docker Container Started (JDK 24)"\n\
echo "=========================================="\n\
echo "Java version:"\n\
java -version\n\
echo ""\n\
\n\
# 查找实际的 Java 路径\n\
ACTUAL_JAVA=$(which java)\n\
echo "Actual Java path: $ACTUAL_JAVA"\n\
\n\
# 创建 BellSoft JDK 兼容路径（使用正确的路径格式）\n\
BELLSOFT_PATH="/usr/lib/jvm/jdk-24.0.2-bellsoft-x86_64"\n\
\n\
if [ ! -f "$BELLSOFT_PATH/bin/java" ]; then\n\
    echo "Creating BellSoft JDK compatibility links at $BELLSOFT_PATH..."\n\
    mkdir -p $BELLSOFT_PATH/bin\n\
    ln -sf $ACTUAL_JAVA $BELLSOFT_PATH/bin/java\n\
    \n\
    # 同时创建其他常用工具的链接\n\
    for tool in javac jshell keytool jar; do\n\
        TOOL_PATH=$(which $tool 2>/dev/null || echo "")\n\
        if [ -n "$TOOL_PATH" ]; then\n\
            ln -sf $TOOL_PATH $BELLSOFT_PATH/bin/$tool\n\
        fi\n\
    done\n\
    \n\
    echo "BellSoft compatibility links created successfully"\n\
else\n\
    echo "BellSoft JDK compatibility links already exist"\n\
fi\n\
\n\
# 同时创建简化的 bellsoft-x86_64 链接\n\
if [ ! -L "/usr/lib/jvm/bellsoft-x86_64" ]; then\n\
    ln -sf $BELLSOFT_PATH /usr/lib/jvm/bellsoft-x86_64 2>/dev/null || true\n\
fi\n\
\n\
# 验证 Java 命令在 BellSoft 路径下可用\n\
if [ -f "$BELLSOFT_PATH/bin/java" ]; then\n\
    echo "BellSoft Java verification: $($BELLSOFT_PATH/bin/java -version 2>&1 | head -1)"\n\
fi\n\
\n\
echo "JavaFX AMD64 libraries available at: /opt/javafx/lib"\n\
ls -la /opt/javafx/lib/ | head -10\n\
echo ""\n\
echo "Looking for JPro application at /jproserver..."\n\
\n\
# 设置 JavaFX 环境变量\n\
export JAVAFX_HOME=/opt/javafx\n\
export JAVAFX_LIB_PATH=$JAVAFX_HOME/lib\n\
\n\
# 检查 JPro 应用是否已挂载\n\
if [ -d "/jproserver" ]; then\n\
    echo "JPro directory found."\n\
    \n\
    # JPro 应用期望的路径是 /jproserver/jfx/linux/\n\
    mkdir -p /jproserver/jfx\n\
    \n\
    if [ ! -d "/jproserver/jfx/linux" ]; then\n\
        echo "Creating JavaFX symlink for JPro application (linux)..."\n\
        ln -sf /opt/javafx/lib /jproserver/jfx/linux\n\
        echo "Symlink created: /jproserver/jfx/linux -> /opt/javafx/lib"\n\
    else\n\
        echo "JavaFX symlink already exists at /jproserver/jfx/linux"\n\
    fi\n\
    \n\
    # 验证符号链接\n\
    echo "Contents of /jproserver/jfx/linux:"\n\
    ls -la /jproserver/jfx/linux/ | head -5\n\
    \n\
    # 查找启动脚本\n\
    if [ -f "/jproserver/bin/restart.sh" ]; then\n\
        echo "Found restart.sh, executing..."\n\
        cd /jproserver\n\
        # 在环境中传递 JavaFX 路径\n\
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

# 设置工作目录
WORKDIR /

# 使用 entrypoint 脚本
ENTRYPOINT ["/entrypoint.sh"]
