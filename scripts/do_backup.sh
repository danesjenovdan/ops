#!/bin/bash

# set backup file name
export DUMP_FILE=${DATABASE_NAME}_db_`date +%Y%m%d_%H%M%S`.pgdump

# dump the database
PGPASSWORD=$DATABASE_PASSWORD \
    pg_dump -U $DATABASE_USER \
        -f $DUMP_FILE \
        -d \
        $DATABASE_NAME

# zip the database
bzip2 $DUMP_FILE

# encrypt the database
mcrypt ${DUMP_FILE}.bz2 -k $DB_BACKUP_PASSWORD

# upload the database to s3
aws s3 cp ${DUMP_FILE}.bz2.nc $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par

# upload the database as latest
cp ${DUMP_FILE}.bz2.nc ${DATABASE_NAME}_db_latest.bz2.nc

aws s3 cp ${DATABASE_NAME}_db_latest.bz2.nc $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par
