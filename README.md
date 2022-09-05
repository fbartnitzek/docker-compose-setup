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

## restore gitea backup
- see [restore](https://docs.gitea.io/en-us/backup-and-restore/#restore-command-restore) and use the period backups


## gitea migration
- breaking changes prevent a simple update and migrating tables isn't feasible for a single-user setup, so migrate via git
- dump all git repos of the existing gitea installation via [backup-repos.sh](gitea_migration/backup-repos.sh)
  - needs GITEA_HOST and GITEA_LOGIN env vars
  - dumps all repos of the user in the current directory with 1 sub-dir per org
- set up a fresh gitea instance with the current db 
- restore your user and recreate the used organizations
- restore all git repos via [restore-repos.sh](gitea_migration/restore-repos.sh)
  - needs GITEA_HOST, GITEA_LOGIN and GITEA_USER env vars
  - restores all repos in the current directory