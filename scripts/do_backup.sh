#!/bin/bash

# set backup file name
export DUMP_FILE=${DATABASE_NAME}_DB_`date +%Y-%m-%d`.pgdump

# dump the database
PGPASSWORD=$POSTGRES_PASSWORD \
    pg_dump -U $POSTGRES_USER \
        -f $DUMP_FILE \
        -d \
        $DATABASE_NAME

# zip the database
bzip2 $DUMP_FILE

# encrypt the database
age -r $AGE_RECIPIENT ${DUMP_FILE}.bz2 > ${DUMP_FILE}.bz2.age

# upload the database to s3
aws s3 cp ${DUMP_FILE}.bz2.age $S3_BACKUP_PATH \
    --endpoint-url=${S3_ENDPOINT_URL} \
    --region=${S3_REGION} \
    --checksum-algorithm=CRC32

# upload the database as latest
cp ${DUMP_FILE}.bz2.age ${DATABASE_NAME}_DB_latest.bz2.age

aws s3 cp ${DATABASE_NAME}_DB_latest.bz2.age $S3_BACKUP_PATH \
    --endpoint-url=${S3_ENDPOINT_URL} \
    --region=${S3_REGION} \
    --checksum-algorithm=CRC32
