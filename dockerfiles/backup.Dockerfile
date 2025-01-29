FROM mdillon/postgis

# HACK: mdillon/postgis runs from postgres 11 on debian stretch
#       postgres removed official support for stretch on 2022-11-07
#       https://www.postgresql.org/message-id/Y2kmqL%2BpCuSZiQBV%40msg.df7cb.de
#       remove this hack when we update to newer postgres docker image
#
#       this replaces apt repo with apt-archive repo
RUN rm /etc/apt/sources.list
RUN rm /etc/apt/sources.list.d/pgdg.list
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list
RUN apt-get update && apt-get -y install apt-transport-https
RUN echo "deb https://apt-archive.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
# END HACK

RUN apt-get update && apt-get install -y python3 python3-pip age

# aws cli install and setup
RUN pip3 install awscliv2 --break-system-packages

RUN awsv2 --install
COPY config/aws.config $HOME/.aws/config

# copy backup script
COPY scripts/do_backup.sh /
RUN chmod +x /do_backup.sh
