FROM alpine:3.22.1
ENV HOME=/home
RUN apk --no-cache add groff
RUN apk update
RUN apk add aws-cli

RUN wget -q https://github.com/FiloSottile/age/releases/download/v1.2.0/age-v1.2.0-linux-amd64.tar.gz
RUN tar -xvf age-v1.2.0-linux-amd64.tar.gz
RUN mv age/age /usr/local/bin/age
RUN chmod +x /usr/local/bin/age

RUN mkdir -p $HOME/.aws
RUN mkdir -p $HOME/.aws/config
COPY config/aws.config $HOME/.aws/config

COPY scripts/static_folder_backup.sh /
RUN chmod +x /static_folder_backup.sh
