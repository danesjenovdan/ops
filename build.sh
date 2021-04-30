#!/bin/bash

sudo docker login rg.fr-par.scw.cloud/djnd -u nologin -p $SCW_SECRET_TOKEN

# BUILD AND PUBLISH BACKUP
sudo docker build -f dockerfiles/backup.Dockerfile -t backup:latest .
sudo docker tag backup:latest rg.fr-par.scw.cloud/djnd/backup:latest
sudo docker push rg.fr-par.scw.cloud/djnd/backup:latest
