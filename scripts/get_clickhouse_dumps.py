import argparse

from subprocess import run, call

parser = argparse.ArgumentParser("Get Clickhouse dumps.")
parser.add_argument("host", help="Clickhouse host name.", type=str)
parser.add_argument("database", help="Clickhouse database name.", type=str)
parser.add_argument("username", help="Clickhouse username.", type=str)
parser.add_argument("password", help="Clickhouse password.", type=str)
args = parser.parse_args()

host = args.host
database = args.database
username = args.username
password = args.password

get_tables_command = [
    "clickhouse-client",
    f"--host={host}",
    f"--query=SELECT table FROM system.tables WHERE database = '{database}'",
    f"--password={password}",
    f"--user={username}",
]


out = run(get_tables_command, capture_output=True)
tables = out.stdout.splitlines()
for table in tables:
    table = table.decode("utf-8")
    print(f"Backap table: {table}")
    get_metadata_command = [
        "clickhouse-client",
        f"--host={host}",
        f"--query=SHOW CREATE TABLE {database}.{table}",
        "--format=TabSeparatedRaw",
        f"--password={password}",
        f"--user={username}",
    ]
    get_data_command = [
        "clickhouse-client",
        f"--host={host}",
        f"--query=SELECT * FROM {database}.{table} FORMAT TabSeparated",
        f"--password={password}",
        f"--user={username}",
    ]
    metadata = open(f"{table}_metadata.tsv", "w")
    data = open(f"{table}_table.tsv", "w")
    call(get_metadata_command, stdout=metadata)
    call(get_data_command, stdout=data)