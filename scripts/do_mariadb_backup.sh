#!/bin/bash

# set backup file name
export DUMP_FILE=${DATABASE_NAME}_db_`date +%Y%m%d_%H%M%S`.sql

# dump the database
mysqldump -A -u $DATABASE_USER -p $MARIADB_PASSWORD $DATABASE_NAME > $DUMP_FILE

# zip the database
bzip2 $DUMP_FILE

# encrypt the database
mcrypt ${DUMP_FILE}.bz2 -k $DB_BACKUP_PASSWORD

# upload the database to s3
aws s3 cp ${DUMP_FILE}.bz2.nc $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par
