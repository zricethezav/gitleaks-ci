#!/bin/bash

PR=""
REPO_SLUG=""
if [ ! -z $TRAVIS_PULL_REQUEST ]; then
    PR=$TRAVIS_PULL_REQUEST
    REPO_SLUG=$TRAVIS_REPO_SLUG
else [ ! -z $CIRCLE_PR_NUMBER ]
    PR=${CIRCLE_PULL_REQUEST##*/}
    REPO_SLUG=$CIRCLE_PROJECT_USERNAME"/"$CIRCLE_PROJECT_REPONAME
fi

PRDIFF=$(curl -u $GITHUB_USERNAME:$GITHUB_API_TOKEN \
     -H 'Accept: application/vnd.github.VERSION.diff' \
     https://api.github.com/repos/$REPO_SLUG/pulls/$PR)

RE=(
    # fork and add/remove whatever you want here
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

echo "checking PR #$PR from $REPO_SLUG"

# iterate diff lines and check for matches
while read -r line; do
    # check for file
    if [[ $line == *"diff --git a"* ]]; then
        filename="${line##* }"
    fi

    for re in "${RE[@]}"; do
        # check regex
        if [[ $line =~ $re ]]; then
            LEAKS+=($line)
            echo "Leak found in ${filename:2}. Offending line: $line"
        fi
    done
done <<< "$PRDIFF"

if [ ! -z "$LEAKS" ]; then
    echo "leaks found, probably shouldn't merge this PR" >&2
    exit 1
else
    echo "no leaks found"
fi
