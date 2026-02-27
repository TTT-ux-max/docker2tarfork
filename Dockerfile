FROM amazoncorretto:24

# 安装 EPEL 仓库和 OpenJFX
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y openjfx && \
    yum install -y \
    pango \
    cairo \
    freetype \
    fontconfig \
    xorg-x11-server-Xvfb \
    && yum clean all

# 验证 OpenJFX 安装
RUN java --module-path /usr/share/java/openjfx/lib --list-modules | grep javafx || echo "OpenJFX installed but modules check failed"

WORKDIR /jproserver

# 设置 JavaFX 模块路径
ENV JAVA_OPTS="--module-path /usr/share/java/openjfx/lib --add-modules javafx.controls,javafx.fxml"
ENV DISPLAY=:99

CMD Xvfb :99 -screen 0 1024x768x24 & cd /jproserver && ./bin/restart.sh
