FROM postgis/postgis:16-3.5-alpine

RUN apk update && apk add --no-cache \
    bash \
    age \
    unzip \
    tar \
    bzip2 \
    curl \
    aws-cli

# setup aws config
RUN mkdir -p /root/.aws
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/do_backup.sh /
RUN chmod +x /do_backup.sh
