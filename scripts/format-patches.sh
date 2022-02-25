#!/bin/bash

# Description:
# Format commits from after a certain point to current HEAD by altering commiter name and email and
# remove internal ticket IDs from commit message.
#
# Usage:
# format-patches.sh <from commit id> <project id> [committer name] [committer email]
#
# [committer name] and [committer email], if left empty, will default to current git user's name and email.
#
# Examples:
# format-patches.sh origin/develop WL
# format-patches.sh origin/develop TH 'Gary Cao' 'gary@barreldev.com'

PATTERN="^.*@barrelny.com$
^.*@barreldev.com$"

from="$1"
project_id="$2"

if [[ "$3" != "" ]]; then
  committer_name="$3"
else
  committer_name=`git config --global user.name`
fi

if [[ "$4" != "" ]]; then
  committer_email="$4"
else
  committer_email=`git config --global user.email`
fi

MATCHES=0
grep -q "$PATTERN" <<< "$GIT_COMMITTER_EMAIL"
MATCHES=$((MATCHES+$?))
grep -q "$PATTERN" <<< "$GIT_AUTHOR_EMAIL"
MATCHES=$((MATCHES+$?))

echo "found ($MATCHES) matches to email exclusion pattern..."

git filter-branch -f --commit-filter "
if [[ "$MATCHES" -gt 0 ]];
then
  GIT_COMMITTER_NAME='${committer_name}';
  GIT_AUTHOR_NAME=\"\$GIT_COMMITTER_NAME\";
  GIT_COMMITTER_EMAIL='${committer_email}';
  GIT_AUTHOR_EMAIL=\"\$GIT_COMMITTER_EMAIL\";
  git commit-tree \"\$@\";
else
  git commit-tree \"\$@\";
fi
" --msg-filter "sed -E 's/^(${project_id}-[[:digit:]]+[[:space:]]+){1,}//g'" ${from}..HEAD
