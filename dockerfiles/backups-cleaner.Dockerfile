FROM python:3.12
RUN apt-get update -y

RUN /usr/local/bin/python -m pip install --upgrade pip

# aws cli install and setup
RUN pip3 install awscliv2==2.3.1 --break-system-packages

# copy backup script
COPY scripts/requirements.txt /
COPY scripts/backups.py /

RUN pip install -r requirements.txt
