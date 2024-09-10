#!/bin/bash

# Load common utility functions and variables
source "$(dirname "$0")/utils.sh"

# Check if the locallocal.env file has been initiated
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
  echo -e "\n\nContainer ${YELLOW}$CONTAINER_NAME${RESET} is already running."
else
  # Check if the container exists but is stopped
  if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
    start_existing_container "$CONTAINER_NAME"
  else
    run_new_container "$CONTAINER_NAME"

    # Check if the container started successfully
    if [ $? -eq 0 ]; then
      echo -e "\n\nContainer ${YELLOW}'$CONTAINER_NAME'${RESET} is running in detached mode."
    else
      echo -e "\n\n${RED}FAILED${RESET} to start the container."
      exit 1
    fi
  fi
fi

echo -e "\nUse the following command to execute commands inside the container:"
echo -e "\n${GREEN}docker exec -it $CONTAINER_NAME <command>${RESET}"
echo -e "\n\nFor example, to start Shopify theme dev:"
echo -e "\n${GREEN}docker exec -it $CONTAINER_NAME shopify theme dev --store='$SHOPIFY_STORE' --verbose${RESET}"
echo -e "\n\nSHOPIFY_STORE: ${YELLOW}$SHOPIFY_STORE${RESET}"
echo -e "THEME_ID: ${YELLOW}$THEME_ID${RESET}\n\n"
