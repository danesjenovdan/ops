
FROM bitnami/postgresql:15.7.0-debian-12-r11
USER root
RUN apt update -y
RUN apt install -y python3 python3-pip age

# aws cli install and setup
RUN pip3 install awscliv2==2.3.1 --break-system-packages

RUN awsv2 --install
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/do_backup.sh /
RUN chmod +x /do_backup.sh
