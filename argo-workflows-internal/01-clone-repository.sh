#!/bin/sh

# Arguments
REPO_URL=$1
GIT_BRANCH=$2
TARGET_DIR="/mnt/vol"
# TARGET_DIR="/tmp/"

# Navigate to the target directory
cd ${TARGET_DIR} || exit

# Clone the repository
git clone --branch "${GIT_BRANCH}" "${REPO_URL}"

# Check if the clone was successful
if [ $? -ne 0 ]; then
  echo "Failed to clone the repository."
  exit 1
fi

echo "Repository cloned successfully."
