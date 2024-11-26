FROM clickhouse/clickhouse-server:24.9.2
RUN apt-get update -y
RUN apt-get install -y python3 python3-pip wget

# age install
RUN wget -q https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
RUN go install filippo.io/age/cmd/...@latest
ENV PATH=$PATH:/root/go/bin

# aws cli install and setup
RUN pip3 install awscli
RUN pip3 install awscli-plugin-endpoint
RUN aws configure set plugins.endpoint awscli_plugin_endpoint
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/do_clickhouse_backup.sh /
COPY scripts/apply_clickhouse_backup.sh /
COPY scripts/get_clickhouse_dumps.py /
RUN chmod +x /do_clickhouse_backup.sh
RUN chmod +x /apply_clickhouse_backup.sh
RUN chmod +x /get_clickhouse_dumps.py
