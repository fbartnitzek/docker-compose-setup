#!/bin/bash

function get_repo_list() {
  # use pagination, limited to 50
  all_repos=
  entries=1
  p=0
  while [[ $entries -gt 0 ]]; do
    ((p++))
    response=$(curl -u "$GITEA_LOGIN" "https://$GITEA_HOST/api/v1/repos/search?sort=created&limit=50&page=$p")
    entries=$(echo "$response" | jq '.data | length')
    if [[ $entries -gt 0 ]]; then
      all_repos=$(printf "%s\n%s" "$all_repos" "$(echo "$response" | jq '.data[].clone_url')")
    fi
  done
}

function git_checkout_all() {
  git fetch --all && git fetch --all --tags
  # checkout every remote branch locally
  for remote in $(git branch -r | grep -v /HEAD); do
    git checkout --track "$remote";
  done
}

if [[ -z "$GITEA_LOGIN" ]] || [[ -z "$GITEA_HOST" ]]; then
  echo "set GITEA_LOGIN and GITEA_HOST"
  echo "additionally use: git config --global credential.helper 'cache --timeout=86400' and use git once"
  exit 1
fi

get_repo_list

echo "found $(echo "$all_repos" | wc -l) repos: $all_repos"

for quotedRepo in $all_repos; do
  repo=$(echo "$quotedRepo" | tr -d '"')
  org=$(echo "$repo" | sed -E 's@^.*/([^/]+)/[^/]+$@\1@g')
  local_dir=$(echo "$repo" | sed -E 's@^.*/([^/]+)\.git\"?$@\1@g')
  echo "repo: $repo of org: $org into $local_dir";

  mkdir -p "$org"
  cd "$org" || exit
  # clone, get all branches and tags
  git clone "$repo"
  cd "$local_dir" || exit
  git_checkout_all
  cd ../..
done