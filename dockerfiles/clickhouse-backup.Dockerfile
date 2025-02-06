FROM clickhouse/clickhouse-server:24.9.2
RUN apt-get update -y
RUN apt-get install -y python3 python3-pip wget

RUN wget -q https://github.com/FiloSottile/age/releases/download/v1.2.0/age-v1.2.0-linux-amd64.tar.gz
RUN tar -xvf age-v1.2.0-linux-amd64.tar.gz
RUN mv age/age /usr/local/bin/age
RUN chmod +x /usr/local/bin/age


# aws cli install and setup
RUN pip3 install awscliv2==2.3.1

RUN awsv2 --install
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/do_clickhouse_backup.sh /
COPY scripts/apply_clickhouse_backup.sh /
COPY scripts/get_clickhouse_dumps.py /
RUN chmod +x /do_clickhouse_backup.sh
RUN chmod +x /apply_clickhouse_backup.sh
RUN chmod +x /get_clickhouse_dumps.py
