#!/bin/bash

# Determine the current branch
branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# Confirm this is what the user intended
read -p "Going to perform a release from branch '$branch', is that correct? Press enter to continue, or ctrl + c to bail."

# User provided version
new_version=v$1

# Get the latest tag for this branch
latest_tag=$(git describe --abbrev=0 --tags)

# Confirm this is what the user intended
read -p "The version will be '$new_version'. The last version was '$latest_tag' The is that correct? Press enter to continue, or ctrl + c to bail."

# Give user the oppurtunity to update files.
read -p "Great. Go update the appropriate meta files (package.json), etc. with the correct version. This script will then commit them with the message 'Release $new_version'. Press enter when you are done."

git commit -am "Release $new_version"

read -p "Great, now we'll push the commit to origin and create tag '$new_version'. Press enter to continue."

git tag $new_version
git push origin --tags
