from typing import Iterator, List

from datetime import datetime, date, timedelta
import sys

import boto3
import click

# setup (based on your ~/.aws-config)
s3_from_config = boto3.resource("s3", endpoint_url="https://s3.fr-par.scw.cloud")


def get_all_files(
    s3=s3_from_config,
    bucket_name="djnd-backups",
):
    backups_bucket = s3.Bucket(bucket_name)
    return backups_bucket.objects.all()


def get_project_name_from_file_name(file_name: str, backup_type: str = "DB",) -> str:
    # this if is to filter out other files
    if f"_{backup_type}_" in file_name and "/" not in file_name:
        return file_name.split(f"_{backup_type}_")[0]

    raise NotImplementedError(f"Can not find project name from {file_name}")


def get_all_projects(s3=s3_from_config, bucket_name="djnd-backups", backup_type="DB") -> List[str]:
    all_files = get_all_files(s3, bucket_name)
    project_names = set()
    for s3_object in all_files:
        if (
            "handpicked" not in s3_object.key
            and "parlamint-before-server-delete" not in s3_object.key
            and "latest" not in s3_object.key
        ):
            project_names.add(get_project_name_from_file_name(s3_object.key, backup_type))
    return list(project_names)


def box_print(text: str) -> None:
    print("####" + "#" * len(text))
    print("# " + text + " #")
    print("####" + "#" * len(text))


def get_date_strings_for_deletion(
    min_date: date,
    max_date: date,
) -> Iterator[str]:
    for i in range((max_date - min_date).days):
        date_candidate = min_date + timedelta(days=i)
        if date_candidate.day != 1:
            yield date_candidate.strftime("%Y-%m-%d")


def filter_project_files(file_name: str, project_name: str) -> bool:
    return project_name + "_DB_" in file_name


def delete_files_from_bucket(
    files_to_delete: list,
    bucket_name: str = "djnd-backups",
    s3=s3_from_config,
) -> None:
    bucket = s3.Bucket(bucket_name)
    bucket.delete_objects(
        Delete={
            "Objects": [{"Key": key} for key in files_to_delete],
            "Quiet": False,
        },
    )


def delete_stale_backups(
    s3=s3_from_config,
    bucket_name: str = "djnd-backups",
    project_name: str = "hudapobuda",
    backup_type: str = "DB",
    cutoff_date: date | None = None,
    force: bool = False,
) -> None:

    # prepare cutoff date
    if cutoff_date is None:
        today = datetime.today()
        cutoff_date = date(today.year, today.month, 1)

    # notify users what's about to happen
    intro_text = f"Deleting project {project_name}!"
    box_print(intro_text)

    # list and count project backup files
    project_backup_files = list(
        filter(
            lambda file_name: filter_project_files(file_name, project_name),
            [item.key for item in get_all_files(s3, bucket_name)],
        )
    )
    print(f"Found {len(project_backup_files)} project files.")

    # prepare list of files to delete
    date_strings_for_deletion = [
        s for s in get_date_strings_for_deletion(date(2022, 1, 1), cutoff_date)
    ]
    files_to_delete = [
        file_name
        for file_name in project_backup_files
        if file_name.split(f"_{backup_type}_")[-1].split(".")[0] in date_strings_for_deletion
        and "latest" not in file_name
    ]

    # if there are files to delete, go and delete them
    if len(files_to_delete) > 0:
        print(f"Deleting {len(files_to_delete)} files.")

        # if force is used, skip user input
        if force:
            delete_files_from_bucket(
                files_to_delete=files_to_delete,
                bucket_name=bucket_name,
                s3=s3,
            )
        else:
            # this will break or exit depending on user input
            while True:
                final_decision = input(
                    f"Are you sure you want to do this? {len(files_to_delete)} files will be deleted. [y/N]"
                )

                if final_decision.upper() == "Y":
                    delete_files_from_bucket(
                        files_to_delete=files_to_delete,
                        bucket_name=bucket_name,
                        s3=s3,
                    )
                    return
                else:
                    print("Deletion aborted. Moving on.")
                    return

    # no backup files should be deleted
    else:
        print("No stale backups to delete. Moving on.\n")


# CLI SETUP
@click.group()
def cli() -> None:
    pass


# COMMAND SETUP
@click.command()
@click.option(
    "--force", is_flag=True, required=False, type=bool, show_default=True, default=False
)
def clean_s3_backups(force: bool) -> None:
    # iterate through all the projects and delete stale database backups for each of them
    for project_name in get_all_projects(
        s3=s3_from_config,
        bucket_name="djnd-backups",
    ):
        delete_stale_backups(
            s3=s3_from_config,
            bucket_name="djnd-backups",
            project_name=project_name,
            force=force,
        )

    # iterate through all the projects and delete stale static backups for each of them
    for project_name in get_all_projects(
        s3=s3_from_config,
        bucket_name="djnd-backup-static",
        backup_type="STATIC",
    ):
        delete_stale_backups(
            s3=s3_from_config,
            bucket_name="djnd-backup-static",
            backup_type="STATIC",
            project_name=project_name,
            force=force,
        )


# ADD COMMAND TO CLI
cli.add_command(clean_s3_backups)

# MAKE CLI RUN WHEN SCRIPT IS RUN
if __name__ == "__main__":
    cli()
