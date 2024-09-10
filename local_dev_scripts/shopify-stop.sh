#!/bin/bash

# Load common utility functions and variables
source "$(dirname "$0")/utils.sh"

# Check if the local.env file has been initiated
check_initiated

# Navigate to the project directory
navigate_to_project

# Load environment variables
load_env

# Check if CONTAINER_NAME variable is set
check_variable "CONTAINER_NAME"

# Check if the container is running
if is_container_running "$CONTAINER_NAME"; then
  echo -e "Stopping and removing the container ${YELLOW}$CONTAINER_NAME${RESET}...\n"

  # Stop the running container
  docker stop "$CONTAINER_NAME"

  # Remove the container
  docker rm "$CONTAINER_NAME"

  echo -e "Container ${YELLOW}$CONTAINER_NAME${RESET} has been stopped and removed.\n"
else
  echo -e "Container ${YELLOW}$CONTAINER_NAME${RESET} is not running.\n"
fi
