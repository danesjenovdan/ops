#!/bin/bash

# get backup

# create backup dir
mkdir backup
cd backup

# get the backup file
wget https://djnd-backups.s3.fr-par.scw.cloud/_clickhouse_20210714_095702.tar.bz2.nc

mdecrypt _clickhouse_20210714_095702.tar.bz2.nc -k $DB_BACKUP_PASSWORD

tar -xf _clickhouse_20210714_095702.tar.bz2 ./

cd _clickhouse_20210714_095702

# dump the database
# clickhouse-client --host=clickhouse.shared --query="CREATE DATABASE plausible"
clickhouse-client --host=clickhouse.shared < events_metadata.tsv
clickhouse-client --host=clickhouse.shared < sessions_metadata.tsv
clickhouse-client --host=clickhouse.shared < schema_migrations_metadata.tsv

clickhouse-client --host=clickhouse.shared --query='INSERT INTO plausible.events format TabSeparated' < events_table.tsv
clickhouse-client --host=clickhouse.shared --query='INSERT INTO plausible.sessions format TabSeparated' < sessions_table.tsv
clickhouse-client --host=clickhouse.shared --query='INSERT INTO plausible.schema_migrations format TabSeparated' < schema_migrations_table.tsv
