FROM mdillon/postgis
RUN apt update -y
RUN apt install -y python3 python3-pip mcrypt

# aws cli install and setup
RUN pip3 install awscli
RUN pip3 install awscli-plugin-endpoint
RUN aws configure set plugins.endpoint awscli_plugin_endpoint
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/do_backup.sh /
RUN chmod +x /do_backup.sh
