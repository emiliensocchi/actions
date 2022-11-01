#!/bin/sh

## Stage 0 ##############################################################

set -e
set -x
GIT_SERVER='github.com'

## Stage 1 ##############################################################

echo "Cloning repository"
git clone "https://x-access-token:$API_TOKEN_GITHUB@$GIT_SERVER/$INPUT_REPOSITORY.git" .
