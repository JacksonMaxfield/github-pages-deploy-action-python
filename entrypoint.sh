#!/bin/sh -l

set -e

if [ -z "$ACCESS_TOKEN" ] && [ -z "$GITHUB_TOKEN" ]
then
  echo "You must provide the action with either a Personal Access Token or the GitHub Token secret in order to deploy."
  exit 1
fi

if [ -z "$BRANCH" ]
then
  echo "You must provide the action with a branch name it should deploy to, for example gh-pages or docs."
  exit 1
fi

if [ -z "$FOLDER" ]
then
  echo "You must provide the action with the folder name in the repository where your compiled page lives."
  exit 1
fi

case "$FOLDER" in /*|./*)
  echo "The deployment folder cannot be prefixed with '/' or './'. Instead reference the folder name directly."
  exit 1
esac

# Gets the commit email/name if it exists in the push event payload.
COMMIT_EMAIL=`jq '.pusher.email' ${GITHUB_EVENT_PATH}`
COMMIT_NAME=`jq '.pusher.name' ${GITHUB_EVENT_PATH}`

# If the commit email/name is not found in the event payload then it falls back to the actor.
if [ -z "$COMMIT_EMAIL" ]
then
  COMMIT_EMAIL="${GITHUB_ACTOR:-github-pages-deploy-action}@users.noreply.github.com"
fi

if [ -z "$COMMIT_NAME" ]
then
  COMMIT_NAME="${GITHUB_ACTOR:-GitHub Pages Deploy Action}"
fi

# Directs the action to the the Github workspace.
cd $GITHUB_WORKSPACE && \

# Configures Git.
git init && \
git config --global user.email "${COMMIT_EMAIL}" && \
git config --global user.name "${COMMIT_NAME}" && \

## Initializes the repository path using the access token.
REPOSITORY_PATH="https://${ACCESS_TOKEN:-"x-access-token:$GITHUB_TOKEN"}@github.com/${GITHUB_REPOSITORY}.git" && \

# Checks to see if the remote exists prior to deploying.
# If the branch doesn't exist it gets created here as an orphan.
if [ "$(git ls-remote --heads "$REPOSITORY_PATH" "$BRANCH" | wc -l)" -eq 0 ];
then
  echo "Creating remote branch ${BRANCH} as it doesn't exist..."
  git checkout "${BASE_BRANCH:-master}" && \
  git checkout --orphan $BRANCH && \
  git rm -rf . && \
  touch README.md && \
  git add README.md && \
  git commit -m "Initial ${BRANCH} commit" && \
  git push $REPOSITORY_PATH $BRANCH
fi

# Checks out the base branch to begin the deploy process.
git checkout $BASE_BRANCH && \

###############################################################################

# We are going to do some weird things here
# GitHub Pages (the place that a lot of these website / doc deployments target)
# doesn't like it when we remove the entire git history of the branch.
# (at least from our testing)
# The next few steps will solve this problem by copying the entire git history
# of the gh-pages branch to the build target folder prior to actually running
# the build script. This means that we will be adding a commit to the history
# instead of always having a single commit in our gh-pages branch which is
# generally also desireable in many cases.

###############################################################################
echo "Preparing for deployment build from $BASE_BRANCH" && \

# Make build dir target
mkdir -p $FOLDER && \

# Clone the repo to the folder so we have the entire project history
git clone $REPOSITORY_PATH $FOLDER && \

# Add current working directory to stack because who knows where we are :upside-down-smiley:
WORKING_DIR=`pwd` && \

# Move to build target
cd $FOLDER && \

# Checkout target branch so we have just the docs / website history
git checkout $BRANCH && \

# Return to main working directory
cd $WORKING_DIR && \

# Builds the project if a build script is provided.
echo "Running build scripts... $BUILD_SCRIPT" && \
eval "$BUILD_SCRIPT" && \

if [ "$CNAME" ]; then
  echo "Generating a CNAME file in in the $FOLDER directory..."
  echo $CNAME > $FOLDER/CNAME
fi

# Commits the data to Github.
echo "Deploying to GitHub..." && \
cd $FOLDER && \

# Either push changes or do nothing because up-to-date
{

    git add -A && \
    git commit -m "Deploying to $BRANCH from $BASE_BRANCH $GITHUB_SHA" --quiet && \
    git push $REPOSITORY_PATH $BRANCH -f --quiet && \
    echo "Deployment successful!"

} || {

    echo "Everything looks up-to-date already!"

}
