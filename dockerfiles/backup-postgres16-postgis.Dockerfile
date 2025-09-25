
FROM postgis/postgis:16-3.5
USER root
ENV HOME=/root
RUN apt update -y
RUN apt install -y age unzip tar bzip2 curl \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# setup aws config
RUN mkdir -p /root/.aws
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/do_backup.sh /
RUN chmod +x /do_backup.sh
