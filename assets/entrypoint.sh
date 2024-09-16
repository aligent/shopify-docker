#!/bin/bash

# Load environment variables from the local.env file inside the container
if [ -f "/shopify/local.env" ]; then
    # Load environment variables, handling potential errors in the local.env format
    export $(grep -v '^#' /shopify/local.env | xargs) || {
        echo "Error: Failed to load environment variables from local.env."
        exit 1
    }
fi

# Check if required environment variables are set before pulling the theme
if [ -z "$SHOPIFY_STORE" ] || [ -z "$THEME_ID" ] || [ -z "$SHOPIFY_ACCESS_TOKEN" ]; then
    echo "Missing required environment variables. Skipping theme pull."
    echo "Required: SHOPIFY_STORE, THEME_ID, SHOPIFY_ACCESS_TOKEN."
    exit 1
fi

# Create a group and user matching the host USER_ID and GROUP_ID to avoid permission issues
if ! id "shopifyuser" &>/dev/null; then
    groupadd -g "$GROUP_ID" shopifygroup && \
    useradd -l -u "$USER_ID" -g shopifygroup -m shopifyuser 2>/dev/null
fi

# Create the /shopify/theme directory if it does not exist and set permissions
if [ ! -d "/shopify/theme" ]; then
    mkdir -p /shopify/theme
fi

# Adjust permissions for the /shopify directory and Shopify CLI assets
chown -R shopifyuser:shopifygroup /shopify
chown -R shopifyuser:shopifygroup /usr/lib/node_modules/@shopify/cli/dist/assets/cli-ruby

# Switch to shopifyuser
su shopifyuser

# Execute the passed command or default to bash
exec "$@"
