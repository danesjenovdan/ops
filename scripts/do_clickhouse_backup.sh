#!/bin/bash

# set backup name
export BACKUP_NAME=${DATABASE_NAME}_clickhouse_DB_`date +%Y-%m-%d`

# create backup dir
mkdir $BACKUP_NAME
cd $BACKUP_NAME

# dump the database
python3 ../get_clickhouse_dumps.py ${CLICKHOUSE_HOST} ${DATABASE_NAME} ${DATABASE_USERNAME} ${DATABASE_PASSWORD}

# # zip the database
cd ..
tar cjvf ${BACKUP_NAME}.tar.bz2 ./${BACKUP_NAME}

# # encrypt the database
age -r $AGE_RECIPIENT ${BACKUP_NAME}.tar.bz2 > ${BACKUP_NAME}.tar.bz2.age

# configure aws - set access key and secret key
awsv2 --configure default ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY}

# upload the database to s3
awsv2 s3 cp ${BACKUP_NAME}.tar.bz2.age $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par \
    --checksum-algorithm=CRC32

# upload the database as latest
cp ${BACKUP_NAME}.tar.bz2.age ${DATABASE_NAME}_clickhouse_DB_latest.tar.bz2.age

awsv2 s3 cp ${DATABASE_NAME}_clickhouse_DB_latest.tar.bz2.age $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par \
    --checksum-algorithm=CRC32
