#!/bin/bash

# set backup file name
ARCHIVE_FILE=${PROJECT_NAME}_MEDIA_`date +%Y-%m-%d`.tar.bz2

# compress folder
tar cjfP $ARCHIVE_FILE $MEDIA_PATH

# encrypt the media folder
age -r $AGE_RECIPIENT ${ARCHIVE_FILE} > ${ARCHIVE_FILE}.age

# configure aws - set access key and secret key
awsv2 --configure default ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY}

# upload the media folder to s3
awsv2 s3 cp ${ARCHIVE_FILE}.age $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par \
    --checksum-algorithm=CRC32

# upload the media folder as latest
cp ${ARCHIVE_FILE}.age ${PROJECT_NAME}_MEDIA_latest.bz2.age

awsv2 s3 cp ${PROJECT_NAME}_MEDIA_latest.bz2.age $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par \
    --checksum-algorithm=CRC32
