#!/bin/bash

# set backup name
export BACKUP_NAME=${DATABASE_NAME}_clickhouse_`date +%Y%m%d_%H%M%S`

# create backup dir
mkdir $BACKUP_NAME
cd $BACKUP_NAME

# dump the database
clickhouse-client --host=clickhouse.shared --query="SHOW CREATE TABLE plausible.events" --format=TabSeparatedRaw > events_metadata.tsv
clickhouse-client --host=clickhouse.shared --query="SHOW CREATE TABLE plausible.sessions" --format=TabSeparatedRaw > sessions_metadata.tsv
clickhouse-client --host=clickhouse.shared --query="SHOW CREATE TABLE plausible.schema_migrations" --format=TabSeparatedRaw > schema_migrations_metadata.tsv

clickhouse-client --host=clickhouse.shared --query "SELECT * FROM plausible.events FORMAT TabSeparated" > events_table.tsv
clickhouse-client --host=clickhouse.shared --query "SELECT * FROM plausible.sessions FORMAT TabSeparated" > sessions_table.tsv
clickhouse-client --host=clickhouse.shared --query "SELECT * FROM plausible.schema_migrations FORMAT TabSeparated" > schema_migrations_table.tsv

# # zip the database
cd ..
tar cjvf ${BACKUP_NAME}.tar.bz2 ./${BACKUP_NAME}

# # encrypt the database
mcrypt ${BACKUP_NAME}.tar.bz2 -k $DB_BACKUP_PASSWORD

# upload the database to s3
aws s3 cp ${BACKUP_NAME}.tar.bz2.nc $S3_BACKUP_PATH \
    --endpoint-url=https://s3.fr-par.scw.cloud \
    --region=fr-par
