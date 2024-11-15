#!/bin/bash

# set backup name
export BACKUP_NAME=${DATABASE_NAME}_clickhouse_`date +%Y%m%d`

# create backup dir
mkdir $BACKUP_NAME
cd $BACKUP_NAME

# dump the database
python3 ../get_clickhouse_dumps.py ${CLICKHOUSE_HOST} ${DATABASE_NAME} ${DATABASE_USERNAME} ${DATABASE_PASSWORD}

# # zip the database
cd ..
tar cjvf ${BACKUP_NAME}.tar.bz2 ./${BACKUP_NAME}

# # encrypt the database
mcrypt ${BACKUP_NAME}.tar.bz2 -k $DB_BACKUP_PASSWORD

# upload the database to s3
aws s3 cp ${BACKUP_NAME}.tar.bz2.nc $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par

# upload the database as latest
cp ${BACKUP_NAME}.tar.bz2.nc ${DATABASE_NAME}_db_latest.tar.bz2.nc

aws s3 cp ${DATABASE_NAME}_db_latest.tar.bz2.nc $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par
