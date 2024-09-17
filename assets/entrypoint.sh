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

# Create the /shopify/theme directory if it does not exist and set permissions
if [ ! -d "/shopify/theme" ]; then
    mkdir -p /shopify/theme
fi

# Check if the user exists; if not, create it with the host's UID and GID
if ! id "shopifyuser" &>/dev/null; then
    groupadd -g "$GROUP_ID" shopifygroup
    useradd -l -u "$USER_ID" -g shopifygroup -m shopifyuser
else
    # Modify the existing shopifyuser to match the current UID and GID if needed
    usermod -u "$USER_ID" shopifyuser
    groupmod -g "$GROUP_ID" shopifygroup
fi

# Adjust permissions for the /shopify directory and Shopify CLI assets
chown -R shopifyuser:shopifygroup /shopify
chown -R shopifyuser:shopifygroup /usr/lib/node_modules/@shopify/cli/dist/assets/cli-ruby

# Execute the passed command or default to bash
exec "$@"