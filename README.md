# docker compose setup
setup to host multiple services with reverse proxy and let's encrypt in front, e.g. with dyndns-provider

## components
- traefik
- giteadb
- gitea
- nextclouddb
- nextcloud

## hints
- when changing the servicename, you change the hostname of that container
    - so when changing db-service-names you have to configure another host in config-file in docker-volume (no service-concept in docker-compose)

## usage
- now using docker compose (v2) instead of docker-compose (v1)
- copy .env.templates to .env and fill all values
- generate file from each template via `./generate_files.sh`
  - dry-run via `./generate_files.sh .diff`, produces diff-files
  - check for errors
  - real run without args

```
docker compose stop
git pull
./generate_files.sh
docker compose up -d
docker compose ps
docker logs traefik
```

## update gitea
- use gitea backup procedure, stop both services and backup and remove db-folder
- install fresh version of postgres
- restore tables via dump
```
psql -U $GITEA_USER -d $GITEA_DB -p 5432 -h localhost < /opt/docker_compose/backup/dump/gitea-db.sql
```
- update gitea image and up