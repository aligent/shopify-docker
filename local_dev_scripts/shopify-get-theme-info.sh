#!/bin/bash

# Load common utility functions and variables
source "$(dirname "$0")/utils.sh"

# Check if the local.env file has been initiated
check_initiated

# Navigate to the project directory
navigate_to_project

# Load environment variables
load_env

# Check if required variables are set
check_variable "SHOPIFY_STORE"
check_variable "SHOPIFY_ACCESS_TOKEN"

# Fetch detailed theme information using the Shopify Admin API
curl -s -X GET "https://$SHOPIFY_STORE/admin/api/2023-07/themes.json" \
  -H "X-Shopify-Access-Token: $SHOPIFY_ACCESS_TOKEN" | jq .
