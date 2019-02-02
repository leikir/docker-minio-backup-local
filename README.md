# minio-backup-local

Backup Minio to local filesystem with periodic backups and rotate backups.
It can backup multiple buckets by setting all bucket names in `MINIO_BUCKET` separated by comas or spaces.

## Usage

Docker:
```sh
$ docker run \
    -v /mnt/data:/data \
    -v /mnt/backups:/backups \
    -e MINIO_DIR=/data \
    -e MINIO_BUCKET=bucketname \
    leikir/minio-backup-local
```

Docker Compose:
```yaml
version: '2'
services:
    minio:
        image: minio/minio
        restart: always
        command: server /data
        volumes:
            - /mnt/data:/data
    minio-backup:
        image: leikir/minio-backup-local
        restart: always
        volumes:
            - /mnt/data:/data
            - /mnt/backups:/backups
        depends_on:
            - minio
        environment:
            - MINIO_DIR=/data
            - MINIO_BUCKET=bucketname
            - SCHEDULE=@daily
            - BACKUP_KEEP_DAYS=7
            - BACKUP_KEEP_WEEKS=4
            - BACKUP_KEEP_MONTHS=6
            - HEALTHCHECK_PORT=80
```

### Manual Backups

By default it makes daily backups but you can start a manual one by running the command `/backup.sh`.

Example running only manual backup on Docker:
```sh
$ docker run \
    -v /mnt/data:/data \
    -v /mnt/backups:/backups \
    -e MINIO_DIR=/data \
    -e MINIO_BUCKET=bucketname \
    leikir/minio-backup-local /backup.sh
```

### Automatic Periodic Backups

You can change the `SCHEDULE` environment variable like `-e SCHEDULE="@daily"` to change its default frequency, by default is daily.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

Folders daily, weekly and monthly are created and populated using hard links to save disk space.
