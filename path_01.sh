#!/bin/bash

echo "[" > apps.json
first=true

for dir in app/*/; do
  id=$(basename "$dir")
  name=$(echo "$id" | sed -e 's/^./\U&/' -e 's/-/ /g')
  avatar_file=$(find "$dir" -iregex ".*\.\(jpg\|jpeg\|png\)" | head -n 1)
  ipk_file=$(find "$dir" -name "*.ipk" | head -n 1)

  [ -z "$ipk_file" ] && continue

  filename=$(basename "$ipk_file")
  base_name="${filename%.ipk}"

  # Detect if underscore format (pkg_version_arch)
  if [[ "$base_name" == *_*_* ]]; then
    package=$(echo "$base_name" | cut -d_ -f1)
    version=$(echo "$base_name" | cut -d_ -f2)
  else
    package=$(echo "$base_name" | sed -E 's/(.*)-v?[0-9].*/\1/')
    version=$(echo "$base_name" | sed -E 's/.*-v?([0-9].*)/\1/')
  fi

  # Add 'v' to version if not present
  if [[ ! "$version" =~ ^v ]]; then
    version="v$version"
  fi

  if [ -n "$avatar_file" ]; then
    avatar_url="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/main/${avatar_file}"
  else
    avatar_url="https://raw.githubusercontent.com/dotywrt/doty_store/main/doty.jpeg"
  fi 

  ipk_url="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/main/${ipk_file}"

  # Get author from author.txt if available
  author_file="$dir/author.txt"
  if [ -f "$author_file" ]; then
    author=$(cat "$author_file" | tr -d '\n')
  else
    author="Unknown"
  fi

  # Get last modified date of ipk file in YYYY-MM-DD format
  updated=$(date -u -r "$ipk_file" +"%Y-%m-%d")

  if [ "$first" = true ]; then
    first=false
  else
    echo "," >> apps.json
  fi

  cat <<EOF >> apps.json
{
  "id": "$id",
  "name": "$name",
  "package": "$package",
  "version": "$version",
  "avatar": "$avatar_url",
  "url": "$ipk_url",
  "author": "$author",
  "updated": "$updated"
}
EOF

done

echo "]" >> apps.json
