#!/bin/sh

pwd
sleep 2
ls -la
sleep 5


## Stage 0 ##############################################################

set -e
set -x

if [[ -z "$INPUT_SOURCE_DIRECTORY" ]]
then
  echo 'Source directory must be defined'
  return 1
fi

if [[ -z "$INPUT_DESTINATION_DIRECTORY" ]]
then
  echo 'Destination directory must be defined'
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
DESTINATION_DIR="$TEMP_DIR/$INPUT_DESTINATION_DIRECTORY"

## Stage 1 ##############################################################

echo "Cloning destination git repository"
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"
git clone --single-branch --branch $DESTINATION_BRANCH "https://x-access-token:$API_TOKEN_GITHUB@$GIT_SERVER/$INPUT_DESTINATION_REPO.git" "$TEMP_DIR"

## Stage 2 ##############################################################

echo "Copying content from source directory to destination directory"
if [[ -d $DESTINATION_DIR ]]
then
  rm -rf "$DESTINATION_DIR"/*
else
  mkdir -p "$DESTINATION_DIR"
fi

cp -R "$(pwd)"/* "$DESTINATION_DIR"

## Stage 3 ##############################################################

echo "Committing changes in destination git repository"
if [[ -z "$INPUT_COMMIT_MESSAGE" ]]
then
  INPUT_COMMIT_MESSAGE="Synchronized from https://$GIT_SERVER/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"
fi

cd "$DESTINATION_DIR"
git add .
if git status | grep -q "Changes to be committed"
then
  git commit --message "$INPUT_COMMIT_MESSAGE"
  echo "Pushing commit to destination git repository"
  git push -u origin HEAD:"$DESTINATION_BRANCH"
else
  echo "No changes detected"
fi
