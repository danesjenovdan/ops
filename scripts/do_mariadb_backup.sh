#!/bin/bash

# set backup file name
export DUMP_FILE='/tmp/'${DATABASE_NAME}_db_`date +%Y%m%d_%H%M%S`.sql

echo "[mysqldump]" > /tmp/.my.cnf
echo 'user='$DATABASE_USER >> /tmp/.my.cnf
echo 'password='$MARIADB_PASSWORD >> /tmp/.my.cnf
echo 'host='$DATABASE_HOST >> /tmp/.my.cnf
echo 'port=3306' >> /tmp/.my.cnf

mysqldump --defaults-extra-file=/tmp/.my.cnf $DATABASE_NAME > $DUMP_FILE

# zip the database
bzip2 $DUMP_FILE

# encrypt the database
mcrypt ${DUMP_FILE}.bz2 -k $DB_BACKUP_PASSWORD

# upload the database to s3
aws s3 cp ${DUMP_FILE}.bz2.nc $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par
