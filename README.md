# docker compose setup
setup to host multiple services with reverse proxy and lets encrypt in front, e.g. with dyndns-provider

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
```
docker compose ps
docker compose stop
docker compose up -d
```