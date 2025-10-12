#!/usr/bin/env bash

latest_hash=$(curl -sL \
                -H "Accept: application/vnd.github+json" \
                -H "X-GitHub-Api-Version: 2022-11-28" \
                https://api.github.com/repos/sunsettrack4/script.service.easyepg-lite/commits/main \
                | jq -r .sha)
current_hash=$(grep "github" Dockerfile | grep -oP "\w{40}")

if [ "$current_hash" == "$latest_hash" ]; then
    echo "Easyepg version is up to date"
    exit 0
fi

echo "Update to $latest_hash"
sed -E -i "/github/s/\w{40}/$latest_hash/g" Dockerfile
echo "sha=$latest_hash" >> $GITHUB_OUTPUT
