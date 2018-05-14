#!/bin/bash

PRDIFF=$(curl -u $GITHUB_USERNAME:$GITHUB_API_TOKEN \
     -H 'Accept: application/vnd.github.VERSION.diff' \
     https://api.github.com/repos/$TRAVIS_REPO_SLUG/pulls/$TRAVIS_PULL_REQUEST)
echo "checking PR #$TRAVIS_PULL_REQUEST from $TRAVIS_REPO_SLUG"

RE=(
    "-----BEGIN PRIVATE KEY-----"
    "-----BEGIN RSA PRIVATE KEY-----"
    "-----BEGIN DSA PRIVATE KEY-----"
    "-----BEGIN OPENSSH PRIVATE KEY-----"
    "AKIA[0-9A-Z]{16}"
    "facebook.*['\"][0-9a-f]{32}['\"]"
    "reddit.*['\"][0-9a-zA-Z]{14}['\"]"
    "twitter.*['\"][0-9a-zA-Z]{35,44}['\"]"
    "heroku.*[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}"
)
LEAKS=()

# iterate diff lines and check for matches
while read -r line; do
    # check for file
    echo $line
    if [[ $line == *"diff --git a"* ]]; then
        filename="${line##* }"
    fi

    for re in "${RE[@]}"; do
        # check regex
        if [[ $line =~ $re ]]; then
            echo "Leak found in ${filename:2}. Offending line: $line"
        fi
    done
done <<< "$PRDIFF"
echo "Leaks: " $LEAKS
