#!/bin/bash

# set backup file name
export DUMP_FILE=${DATABASE_NAME}_DB_`date +%Y-%m-%d`.pgdump

# dump the database
PGPASSWORD=$DATABASE_PASSWORD \
    pg_dump -U $DATABASE_USER \
        -f $DUMP_FILE \
        -d \
        $DATABASE_NAME

# zip the database
bzip2 $DUMP_FILE

# encrypt the database
age -r $AGE_RECIPIENT ${DUMP_FILE}.bz2 > ${DUMP_FILE}.bz2.age

# configure aws - set access key and secret key
awsv2 --configure default ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY}

# upload the database to s3
awsv2 s3 cp ${DUMP_FILE}.bz2.age $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par

# upload the database as latest
cp ${DUMP_FILE}.bz2.age ${DATABASE_NAME}_DB_latest.bz2.age

awsv2 s3 cp ${DATABASE_NAME}_DB_latest.bz2.age $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par
