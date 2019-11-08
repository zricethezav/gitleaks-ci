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
    "-----BEGIN DSA PRIVATE KEY-----"
    "-----BEGIN OPENSSH PRIVATE KEY-----"
    "AKIA[0-9A-Z]{16}"
    "AIza[0-9A-Za-z\-_]{35}"
    "\"type\": \"service_account\""
    "[0-9]+-[0-9A-Za-z_]{32}\.apps\.googleusercontent\.com"
    "ya29\.[0-9A-Za-z\-_]+"
    "rk_live_[0-9a-zA-Z]{24}"
    "access_token\$production\$[0-9a-z]{16}\$[0-9a-f]{32}"
    "sq0csp-[0-9A-Za-z\-_]{43}"
    "[0-9]+-[0-9A-Za-z_]{32}\.apps\.googleusercontent\.com"
    "[g|G][i|I][t|T][h|H][u|U][b|B].*['|\"][0-9a-zA-Z]{35,40}['|\"]"
    "[t|T][w|W][i|I][t|T][t|T][e|E][r|R].*[1-9][0-9]+-[0-9a-zA-Z]{40}"
    "EAACEdEose0cBA[0-9A-Za-z]+"
    "[s|S][e|E][c|C][r|R][e|E][t|T].*['|\"][0-9a-zA-Z]{32,45}['|\"]"
    "[0-9a-f]{32}-us[0-9]{1,2}"
    "[h|H][e|E][r|R][o|O][k|K][u|U].*[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}"
    "[0-9]+-[0-9A-Za-z_]{32}\.apps\.googleusercontent\.com"
    "sq0atp-[0-9A-Za-z\-_]{22}"
    "AIza[0-9A-Za-z\-_]{35}"
    "https://hooks.slack.com/services/T[a-zA-Z0-9_]{8}/B[a-zA-Z0-9_]{8}/[a-zA-Z0-9_]{24}"
    "[a-zA-Z]{3,10}://[^/\s:@]{3,20}:[^/\s:@]{3,20}@.{1,100}[\"'\s]"
    "[0-9]+-[0-9A-Za-z_]{32}\.apps\.googleusercontent\.com"
    "-----BEGIN RSA PRIVATE KEY-----"
    "AIza[0-9A-Za-z\-_]{35}"
    "key-[0-9a-zA-Z]{32}"
    "amzn\.mws\.[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
    "sk_live_[0-9a-z]{32}"
    "AIza[0-9A-Za-z\-_]{35}"
    "-----BEGIN PGP PRIVATE KEY BLOCK-----"
    "sk_live_[0-9a-zA-Z]{24}"
    "-----BEGIN EC PRIVATE KEY-----"
    "AIza[0-9A-Za-z\-_]{35}"
    "[f|F][a|A][c|C][e|E][b|B][o|O][o|O][k|K].*['|\"][0-9a-f]{32}['|\"]"
    "[t|T][w|W][i|I][t|T][t|T][e|E][r|R].*['|\"][0-9a-zA-Z]{35,44}['|\"]"
    "[a|A][p|P][i|I][_]?[k|K][e|E][y|Y].*['|\"][0-9a-zA-Z]{32,45}['|\"]"
    "SK[0-9a-fA-F]{32}"
    "(xox[p|b|o|a]-[0-9]{12}-[0-9]{12}-[0-9]{12}-[a-z0-9]{32})"
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
