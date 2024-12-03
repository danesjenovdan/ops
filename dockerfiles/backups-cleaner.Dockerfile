FROM python:3.12
RUN apt-get update -y

RUN /usr/local/bin/python -m pip install --upgrade pip

# aws cli install and setup
RUN pip3 install awscli --break-system-packages
RUN pip3 install awscli-plugin-endpoint --break-system-packages
RUN aws configure set plugins.endpoint awscli_plugin_endpoint
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/requirements.txt /
COPY scripts/backups.py /

RUN pip install -r requirements.txt