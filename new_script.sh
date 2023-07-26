#!/bin/bash

# Function to display error messages
function error {
    echo "Error: $1"
    exit 1
}

# Function to backup the current folder
function backup_folder {
    local timestamp=$(date +%Y%m%d%H%M%S)
    local backup_dir="./backups"
    local project_dir="./"

    cp -r "$project_dir" "$backup_dir/$timestamp" || error "Failed to create backup"
    echo "Backup created successfully."
}

# Function to pull changes and build the application
function pull_and_build {
    local branch_name="$1"

    git checkout "$branch_name" || error "Failed to switch to $branch_name branch"
    git pull origin "$branch_name" || error "Failed to pull changes from $branch_name branch"
    
    # Assuming you use npm for building the React project
    npm install || error "Failed to install npm packages"
    npm run build || error "Failed to build the application"
}

# Main script

# Check if there are any changes in the remote repository
#
# Ask the user for the branch they want to update
read -p "Which branch would you like to pull and build? (development/staging/production): " branch_name

git fetch || error "Failed to fetch changes from the remote repository"

# Check if the current branch is tracking a remote branch
if [ -n "$(git ls-remote --exit-code origin "$branch_name")" ]; then
  # Compare the local and remote branches to check for any differences
  git fetch
  if git diff HEAD..origin/"$branch_name" --exit-code; then
    echo "No changes in the remote repository."
    exit 1
  else
    # Step 2: If there are changes, pull them from the remote repository
    git pull origin "$branch_name"

    # Backup the current folder
    backup_folder
    
    # Update the chosen branch
    pull_and_build "$branch_name"
  fi
else
  echo "The current branch is not tracking a remote branch. Please configure tracking."
  exit 1
fi

echo "Update process completed successfully."
