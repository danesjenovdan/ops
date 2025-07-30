FROM python:3.12
USER root
ENV HOME=/tmp
RUN apt-get update -y

RUN /usr/local/bin/python -m pip install --upgrade pip

# aws cli install and setup
RUN pip3 install awscliv2==2.3.1 --break-system-packages

RUN wget -q https://github.com/FiloSottile/age/releases/download/v1.2.0/age-v1.2.0-linux-amd64.tar.gz
RUN tar -xvf age-v1.2.0-linux-amd64.tar.gz
RUN mv age/age /usr/local/bin/age
RUN chmod +x /usr/local/bin/age

RUN awsv2 --install
COPY config/aws.config $HOME/.aws/config


# TODO copy backup script
COPY scripts/static_folder_print_files.sh /
RUN chmod +x /static_folder_print_files.sh