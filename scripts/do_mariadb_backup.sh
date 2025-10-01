#!/bin/bash

# set backup file name
export DUMP_FILE='/tmp/'${DATABASE_NAME}_DB_`date +%Y-%m-%d`.sql

echo "[mariadb-dump]" > /tmp/.my.cnf
echo 'user='$MARIA_USER >> /tmp/.my.cnf
echo 'password='$MARIA_PASSWORD >> /tmp/.my.cnf
echo 'host='$MARIA_HOST >> /tmp/.my.cnf
echo 'port=3306' >> /tmp/.my.cnf

mariadb-dump --defaults-extra-file=/tmp/.my.cnf $DATABASE_NAME > $DUMP_FILE

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
