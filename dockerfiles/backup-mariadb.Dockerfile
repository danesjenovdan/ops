FROM bitnami/mariadb:10.6-debian-12
USER root
RUN apt-get update -y
RUN apt-get install -y python3 python3-pip age

# aws cli install and setup
RUN pip3 install awscli --break-system-packages
RUN pip3 install awscli-plugin-endpoint --break-system-packages
RUN aws configure set plugins.endpoint awscli_plugin_endpoint
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/do_mariadb_backup.sh /
RUN chmod +x /do_mariadb_backup.sh
