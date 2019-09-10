#!/bin/bash

# Dependencies:
#  git CLI
#  hub CLI
#
# Usage:
#   release 1.0.0
#
# This script will:
#   - Create a release commit, like "Release v1.0.0" and push it to "origin"
#   - Create a tag, "v1.0.0" and push it to "origin"
#   - Create a new draft release, with all commits since the previous tag
#
# After running this script, you should follow the link to the draft release
# and manually publish it after reviewing it.
#
# This release script works best when using "Squash + Merge" to create
# commits.
#

# Determine the current branch
branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# Confirm this is what the user intended
read -p "Going to perform a release from branch '$branch', is that correct?
Press enter to continue.."

# User provided version
new_version=v$1

# Get the latest tag for this branch
latest_tag=$(git describe --abbrev=0 --tags)

# Confirm this is what the user intended
read -p "
New version: '$new_version'.
Previous version: '$latest_tag'

Is this correct?
Press enter to continue..."

# Give user the oppurtunity to update files.
read -p "
Update the appropriate meta files package.json). This script will then commit them with the message 'Release $new_version'.
Press enter to continue when you are done..."

git commit -am "Release $new_version"
git push origin $branch

read -p "
Great, now we'll push the commit to origin and create tag '$new_version'.
Press enter to continue..."

git tag $new_version
git push origin $new_version

echo "
Refreshing tags..."

git pull origin $branch --tags

echo "
Comments since last tag:"
commits=$(git log $latest_tag..HEAD~1 --oneline | cut -d' ' -f 2-)

echo $commits

echo "
Creating release $new_version"
hub release create $new_version -m "$new_version
$commits
"

echo "A draft release has been created, follow the printed link to finish publishing."
