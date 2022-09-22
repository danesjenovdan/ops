FROM yandex/clickhouse-client:latest
RUN apt update -y
RUN apt install -y python3 python3-pip mcrypt wget

# aws cli install and setup
RUN pip3 install awscli
RUN pip3 install awscli-plugin-endpoint
RUN aws configure set plugins.endpoint awscli_plugin_endpoint
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/do_clickhouse_backup.sh /
COPY scripts/apply_clickhouse_backup.sh /
RUN chmod +x /do_clickhouse_backup.sh
RUN chmod +x /apply_clickhouse_backup.sh
