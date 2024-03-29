#!/bin/bash

function generate_file() {
  file="$1$diff"
  template_file="$1.template"
  keys="${@:2}"
  echo "# generating $file with $template_file and keys $keys"
  if [ ! -f "$template_file" ]; then
    echo "ERROR: template file $template_file does not exist - aborting"
    exit 1
  fi
  cp $template_file $file
  for key in $keys; do
    value=$(cat .env | grep "$key=" | sed -r "s/^$key=(.*)$/\1/")
    if [ -z "$value" ]; then
      echo "ERROR: no value given for $key - aborting"
      exit 1
    fi
    if [[ "$value" =~ ^\'.*\'$ ]]; then
      value="${value:1:-1}"
    fi
    sed -i "s|<$key>|$value|g" $file
  done
  missing_keys=$(cat $file | grep "<")
  if [ -n "$missing_keys" ]; then
    echo "ERROR: missing keys in generated file $file - aborting: $missing_keys"
    exit 1
  fi
}

diff=$1
if [ -n "$diff" ]; then
  echo "diff mode, using $diff as file-extension"
else
  echo "normal mode, using no file-extension like '.diff'"
fi

generate_file traefik.yml TRAEFIK_USER TRAEFIK_USER_TOKEN EMAIL
generate_file giteadb.env GITEA_DB_USER GITEA_DB_PASSWORD GITEA_DB_NAME
generate_file nextclouddb.env NEXTCLOUD_DB_ROOT_PASSWORD NEXTCLOUD_DB_DATABASE NEXTCLOUD_DB_USER NEXTCLOUD_DB_PASSWORD
