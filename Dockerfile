FROM amazoncorretto:21
# Update yum and install dependencies
RUN yum update -y && yum install -y \
    pango \
    cairo \
    freetype \
    fontconfig && \
    yum clean all
# Set the working directory and configure the CMD
WORKDIR /jproserver
CMD ["sh", "-c", "cd /jproserver && ./bin/restart.sh"]
