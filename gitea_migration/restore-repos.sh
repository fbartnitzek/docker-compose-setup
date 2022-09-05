#!/bin/bash

function search_org_repo(){
  # use pagination, limited to 50
  entries=1
  found_repo=
  p=0
  while [[ $entries -gt 0 ]]; do
    ((p++))
    response=$(curl -u "$GITEA_LOGIN" "https://$GITEA_HOST/api/v1/orgs/${org}/repos?limit=50&page=$p")
    entries=$(echo "$response" | jq '. | length')
    if [[ $entries -gt 0 ]]; then
      found_repo=$(echo "$response" | jq '.[] | select(.name == "$name") | .name')
    fi
  done
}

function git_push(){
  cd "$org/$name" || exit
  found_url=$(git remote -v | grep "$clone_url")
  if [[ -z "$found_url" ]]; then
    echo "swapping remote to $found_url"
    git remote set-url origin "$clone_url"
  else
    echo "unchanged remote $clone_url"
  fi

  git push origin --all
  git push origin --tags

  echo "push for $org/$name done"

  cd ../..
}


if [[ -z "$GITEA_LOGIN" ]] || [[ -z "$GITEA_HOST" ]] || [[ -z "$GITEA_USER" ]]; then
  echo "set GITEA_LOGIN and GITEA_HOST and GITEA_USER"
  echo "additionally use: git config --global credential.helper 'cache --timeout=86400' and use git once"
  exit 1
fi

for org in *; do
  if [[ "$org" == "$GITEA_USER" ]]; then
    echo "user $org"
    for repo in "$org"/*; do
      name=$(echo "$repo" | sed -E 's@^.*/([^/]+)$@\1@g')
      echo "repo: $name - $repo"

      # search
      out=$(curl -u "$GITEA_LOGIN" "https://$GITEA_HOST/api/v1/repos/${org}/${name}" | jq '.id')
      if [[ -n "$out" ]] && [[ "$out" != "null" ]]; then
        echo "repo $repo exists"
      else
        echo "creating repo $repo"
        out=$(curl -X POST -u "$GITEA_LOGIN" -H 'Content-Type: application/json' "https://$GITEA_HOST/api/v1/user/repos" -d "{\"Name\":\"${name}\"}")
        clone_url=$(echo "$out" | jq '.clone_url' | tr -d '"')

        git_push
      fi

    done
  else
    echo "org $org"
    for repo in "$org"/*; do
      name=$(echo "$repo" | sed -E 's@^.*/([^/]+)$@\1@g')
      echo "repo: $name - $repo"

      search_org_repo
      if [[ -n "$found_repo" ]]; then
        echo "repo $repo exists"
      else
        echo "creating repo $repo"

        out=$(curl -X POST -u "$GITEA_LOGIN" -H 'Content-Type: application/json' "https://$GITEA_HOST/api/v1/orgs/${org}/repos" -d "{\"name\":\"${name}\",\"auto_init\":false}")
        clone_url=$(echo "$out" | jq '.clone_url' | tr -d '"')

        git_push
      fi
    done
  fi
done
