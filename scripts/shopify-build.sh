#!/bin/bash

# Load common utility functions and variables
source "$(dirname "$0")/utils.sh"

# Navigate to the project directory
navigate_to_project

# Load environment variables
load_env

# Check if IMAGE_NAME variable is set
check_variable "IMAGE_NAME"

# Build the Docker image with the current user's UID and GID
echo -e "Building Docker image '$IMAGE_NAME' with USER_ID=$(id -u) and GROUP_ID=$(id -g)..."
docker build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) --progress=plain -t "$IMAGE_NAME" .

# Check if the build was successful
if [ $? -eq 0 ]; then
  echo -e "Docker image '$IMAGE_NAME' built successfully."
else
  echo -e "Failed to build Docker image '$IMAGE_NAME'."
  exit 1
fi
