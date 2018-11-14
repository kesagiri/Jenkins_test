#!/bin/bash

#Set GitHub commit status:
#params: 1 - commit state(success/failure/pending), 2 - commit status description, 3 - commit context

GITHUB_ORG=$1
GITHUB_REPO=$2
ACTUAL_COMMIT=$3
GITHUB_ACCESS_TOKEN="../$4"
GITHUB_PROJECT_CONTEXT=$5
BUILD_URL=$6
STATUS=$7
MESSAGE=$8

curl "https://api.github.com/repos/$GITHUB_ORG/$GITHUB_REPO/statuses/$ACTUAL_COMMIT?access_token=$GITHUB_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  -d "{\"state\": \"$STATUS\", \"description\": \"$MESSAGE\", \"target_url\": \"$BUILD_URL/console\", \"context\": \"$GITHUB_PROJECT_CONTEXT\"}" \
  -s > /dev/null #Hide curl output

exit 0