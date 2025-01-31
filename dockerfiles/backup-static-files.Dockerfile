FROM python:3.11-slim

ENV HOME=/aws

RUN apt update -y
RUN apt install -y wget tar
RUN pip3 install --upgrade pip
RUN pip3 install awscliv2==2.0.2

RUN wget -q https://github.com/FiloSottile/age/releases/download/v1.2.0/age-v1.2.0-linux-amd64.tar.gz
RUN tar -xvf age-v1.2.0-linux-amd64.tar.gz
RUN mv age/age /usr/local/bin/age
RUN chmod +x /usr/local/bin/age

# aws cli install and setup
RUN awsv2 --install
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/static_folder_backup.sh /
RUN chmod +x /static_folder_backup.sh
