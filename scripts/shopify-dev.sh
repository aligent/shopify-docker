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

# Run the Shopify theme development command inside the container
docker exec -it "$CONTAINER_NAME" shopify theme dev --store="$SHOPIFY_STORE" --password="$SHOPIFY_ACCESS_TOKEN" --nodelete
