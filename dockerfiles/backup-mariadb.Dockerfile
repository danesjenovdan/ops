FROM mariadb:12.0.2
USER root
RUN apt-get update -y
RUN apt-get install -y age unzip tar bzip2 curl \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# setup aws config
RUN mkdir -p /root/.aws
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/do_mariadb_backup.sh /
RUN chmod +x /do_mariadb_backup.sh
