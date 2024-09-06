#!/bin/bash

# Load common utility functions and variables
source "$(dirname "$0")/utils.sh"

# Navigate to the project directory
navigate_to_project

# Load environment variables
load_env

# Check if SHOPIFY_STORE and CONTAINER_NAME variables are set
check_variable "SHOPIFY_STORE"
check_variable "CONTAINER_NAME"

# Check if the container is already running
if is_container_running "$CONTAINER_NAME"; then
  echo "Container '${YELLOW}$CONTAINER_NAME${RESET}' is already running."
else
  # Check if the container exists but is stopped
  if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
    start_existing_container "$CONTAINER_NAME"
  else
    run_new_container "$CONTAINER_NAME"

    # Check if the container started successfully
    if [ $? -eq 0 ]; then
      echo "Container '${YELLOW}$CONTAINER_NAME${RESET}' is running in detached mode."
    else
      echo "Failed to start the container."
      exit 1
    fi
  fi
fi

# Notify the user that the action will overwrite the theme folder
echo -e "\nThis action will OVERWRITE the contents of the 'theme' folder."
echo -e "\n\nAre you sure you want to proceed? Type YES to continue, or any other key to cancel."

# Read user input
read -r user_input

# Check if the user input is exactly "YES"
if [ "$user_input" == "YES" ]; then
    # Proceed with the deletion and pull action
    rm -rf theme/*
    echo -e "\nPulling the production theme from Shopify...\n\n"
    docker exec -it "$CONTAINER_NAME" shopify theme pull --store="$SHOPIFY_STORE" --password="$SHOPIFY_ACCESS_TOKEN" --theme="$THEME_PRODUCTION_ID" 
else
    # Cancel the action
    echo -e "Action cancelled.\nAborted shopify theme pull.\n The 'theme' folder was not overwritten."
fi
