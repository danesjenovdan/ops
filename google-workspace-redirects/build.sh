#!/bin/bash

docker login rg.fr-par.scw.cloud/djnd -u nologin -p $SCW_SECRET_TOKEN

docker build -f Dockerfile -t google-workspace-redirects:latest .
docker tag google-workspace-redirects:latest rg.fr-par.scw.cloud/djnd/google-workspace-redirects:latest
docker push rg.fr-par.scw.cloud/djnd/google-workspace-redirects:latest
