# Kimai

Self-hosted [Kimai](https://www.kimai.org/) time tracker.

- Image: `kimai/kimai2:2` (all-in-one apache, port 8001)
- Namespace: `kimai`
- URL: https://kimai.lb2.djnd.si
- Database: shared MariaDB (`mariadb-djnd.shared:3306`)
- Uploaded files (`/opt/kimai/var/data`) go to a 1Gi `scw-bssd-retain` PVC

## Prerequisites: create the database

Kimai runs its own schema migrations on first boot and creates the admin user from `ADMINMAIL`/`ADMINPASS`, but it does **not** create the database. To create on shared MariDB:

```sh
kubectl -n shared exec -it deploy/mariadb-djnd -- \
  mariadb -u root -p"$MARIADB_ROOT_PASSWORD" -e "
    CREATE DATABASE IF NOT EXISTS kimai CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS 'kimai'@'%' IDENTIFIED BY '<password>';
    GRANT ALL PRIVILEGES ON kimai.* TO 'kimai'@'%';
    FLUSH PRIVILEGES;
  "
```

Use the same `<password>` in `DATABASE_URL` below.

## Deploy

```sh
cp secret.example.yaml secret.yaml   # then fill in the values
kubectl apply -k .
```

Generate the `APP_SECRET` with `openssl rand -hex 32`.

Once the pod is running, log in with the `ADMINMAIL` / `ADMINPASS` credentials.
