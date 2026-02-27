FROM amazoncorretto:24

RUN yum update -y && \
    yum install -y openjfx && \
    yum clean all

WORKDIR /jproserver

# 使用无头模式
ENV _JAVA_OPTIONS="-Djavafx.platform=Headless -Djava.awt.headless=true"

CMD ["sh", "-c", "cd /jproserver && ./bin/restart.sh"]
