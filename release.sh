#!/bin/bash

# Dependencies:
#  git CLI
#  hub CLI
#
# Usage:
#   release <- Prints the latest release
#   release 1.0.0 <- New release as "v1.0.0"
#   release -s 1.0.0 <- New release as "1.0.0"
#
# Options:
#   -s | --skip-v-prefix - Don't prefix version with "v"
#   -u | --upstream-remote-name - Specify upstream remote name (Default is 'upstream')
#
# This script will:
#   - Create a release commit, like "Release v1.0.0" and push it to "upstream"
#   - Create a tag, "v1.0.0" and push it to "upstream"
#   - Create a new draft release, with all commits since the previous tag
#
# After running this script, you should follow the link to the draft release
# and manually publish it after reviewing it.
#
# This release script works best when using "Squash + Merge" to create
# commits.
#

V_PREFIX='v'
UPSTREAM_REMOTE_NAME='upstream'

# Boilerplate parameter parsing
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -u|--upstream-remote-name)
      UPSTREAM_REMOTE_NAME="$2"
      shift 2
      ;;
    -s|--skip-v-prefix)
      V_PREFIX=''
      shift 1
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

echo "
Refreshing tags..."
git pull $UPSTREAM_REMOTE_NAME $branch --tags

# Get the latest tag for this branch
latest_tag=$(git describe --abbrev=0 --tags)

# If no version is provided, just print the latest released version
if [ -z "$1" ]
then
  echo "The latest release is $latest_tag"
  exit 0
fi

set -- "$1"
IFS="."; declare -a Array=($*)
major="${Array[0]}"
minor="${Array[1]}"
patch="${Array[2]}"

if [ -z "$major" ] || [ -z "$minor" ] || [ -z "$patch" ]
then
  echo "Please provide a full semantic version number"
  exit 1
fi

# User provided version
new_version=$V_PREFIX$major.$minor.$patch

# Determine the current branch
branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# Confirm this is what the user intended
read -p "Going to perform a release from branch '$branch' on remote '$UPSTREAM_REMOTE_NAME', is that correct?
Press enter to continue.."

# Confirm this is what the user intended
read -p "
Previous version: '$latest_tag'
New version: '$new_version'

Is this correct?
Press enter to continue..."

# Give user the opportunity to update files.
read -p "
Update the appropriate meta files (package.json). This script will then commit them with the message 'Release $new_version'.
Press enter to continue when you are done..."

git commit -am "Release $new_version"
git push $UPSTREAM_REMOTE_NAME $branch

read -p "
Great, now we'll push the commit to upstream and create tag '$new_version'.
Press enter to continue..."

git tag $new_version
git push $UPSTREAM_REMOTE_NAME $new_version

minor_branch_name = $major.$minor
if [ `git branch --list $minor_branch_name` ]
then
  echo "
  A branch for this minor, $minor_branch_name, already exists, continuing.
  Press enter to continue..."
else
  read -p "
  A branch for this minor, $minor_branch_name, does not yet exist, this script will not create one and push it upstream.
  Press enter to continue..."

  git checkout -b $minor_branch_name
  git push $UPSTREAM_REMOTE_NAME $minor_branch_name
fi

echo "
Commits since last tag:"
commits=$(git log $latest_tag..HEAD~1 --oneline | cut -d' ' -f 2-)

echo "
Creating release $new_version"
hub release create $new_version -d -m "$new_version
$commits
"

echo "A draft release has been created, follow the printed link to finish publishing."
