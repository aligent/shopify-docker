#!/bin/bash

# Load common utility functions and variables
source "$(dirname "$0")/utils.sh"

# Check if the local.env file has been initiated
check_initiated

# Navigate to the project directory
navigate_to_project

# Load environment variables
load_env

# Check if SHOPIFY_STORE and CONTAINER_NAME variables are set
check_variable "SHOPIFY_STORE"
check_variable "CONTAINER_NAME"

# Check if the container is already running
if is_container_running "$CONTAINER_NAME"; then
  echo -e "Container '${YELLOW}$CONTAINER_NAME${RESET}' is already running."
else
  # Check if the container exists but is stopped
  if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
    start_existing_container "$CONTAINER_NAME"
  else
    run_new_container "$CONTAINER_NAME"

    # Check if the container started successfully
    if [ $? -eq 0 ]; then
      echo -e "Container '${YELLOW}$CONTAINER_NAME${RESET}' is running in detached mode."
    else
      echo -e "Failed to start the container."
      exit 1
    fi
  fi
fi


docker exec -it "$CONTAINER_NAME" shopify theme list --store="$SHOPIFY_STORE" --password="$SHOPIFY_ACCESS_TOKEN"  

