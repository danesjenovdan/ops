
FROM bitnami/postgresql:15.7.0-debian-12-r11
USER root
RUN apt update -y
RUN apt install -y python3 python3-pip mcrypt

# aws cli install and setup
RUN apt install python3-awscli
RUN apt install python3-awscli-plugin-endpoint
USER 1001

RUN aws configure set plugins.endpoint awscli_plugin_endpoint
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/do_backup.sh /
RUN chmod +x /do_backup.sh
