FROM postgis/postgis:16-3.5

# remove debian-security repository from sources list (eol, broken)
RUN sed -i '/debian-security/s/^/#/' /etc/apt/sources.list
# add snapshot (latest is eol and broken)
RUN echo "deb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/20260903T220410Z/ bullseye-security main" >> /etc/apt/sources.list

RUN apt-get update -y
RUN apt-get install -y age unzip tar bzip2 curl \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# setup aws config
RUN mkdir -p /root/.aws
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/do_backup.sh /
RUN chmod +x /do_backup.sh
