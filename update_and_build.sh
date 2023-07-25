#!/bin/bash

# Step 1: Check for changes in the remote repository
git remote update

# Get the name of the current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

echo "Current branch: $current_branch"

# Check if the current branch is tracking a remote branch
if [ -n "$(git ls-remote --exit-code origin "$current_branch")" ]; then
  # Compare the local and remote branches to check for any differences
  git fetch
  if git diff HEAD..origin/"$current_branch" --exit-code; then
    echo "No changes in the remote repository."
    exit 1
  else
    # Step 2: If there are changes, pull them from the remote repository
    git pull origin "$current_branch"
  fi
else
  echo "The current branch is not tracking a remote branch. Please configure tracking."
  exit 1
fi

# Step 3: Build the React app
npm run build
