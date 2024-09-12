#!/bin/bash

# Load environment variables from the local.env file inside the container
if [ -f "/shopify/local.env" ]; then
    # Load environment variables, handling potential errors in the local.env format
    export $(grep -v '^#' /shopify/local.env | xargs) || {
        echo "Error: Failed to load environment variables from local.env."
        exit 1
    }
fi

# Debugging output: Check if environment variables are set
echo "SHOPIFY_STORE: $SHOPIFY_STORE"
echo "THEME_ID: $THEME_ID"
echo "SHOPIFY_ACCESS_TOKEN: $SHOPIFY_ACCESS_TOKEN"
echo "Running as user: $(whoami)"
echo "Current USER_ID: $(id -u)"
echo "Current GROUP_ID: $(id -g)"
echo "Checking permissions on /shopify/theme:"
ls -ld /shopify/theme

# Check if theme ID and store are set, if so, pull the theme
if [ -n "$SHOPIFY_STORE" ] && [ -n "$THEME_ID" ] && [ -n "$SHOPIFY_ACCESS_TOKEN" ]; then
    echo "Pulling theme from Shopify..."
    # Execute the shopify theme pull command and check for success or failure
    shopify theme pull --store=$SHOPIFY_STORE --theme=$THEME_ID --password=$SHOPIFY_ACCESS_TOKEN
    if [ $? -ne 0 ]; then
        echo "Error: Failed to pull theme from Shopify. Check if the credentials are correct and have the necessary permissions."
        # exit 1
    else
        echo "Successfully pulled the theme from Shopify."
    fi
else
    echo "Missing required environment variables. Skipping theme pull."
    echo "Required: SHOPIFY_STORE, THEME_ID, SHOPIFY_ACCESS_TOKEN."
fi

# Execute the passed command or default to bash
exec "$@"
