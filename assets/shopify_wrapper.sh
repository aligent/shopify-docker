#!/bin/bash


# Load environment variables from the local.env file inside the container
if [ -f "/shopify/local.env" ]; then
    export $(grep -v '^#' /shopify/local.env | xargs)
fi

# Block 'shopify theme push' command
if [[ "$1" == "theme" && "$2" == "push" ]]; then
    echo "Error: 'shopify theme push' command is disabled in this environment."
    exit 1

# Modify 'shopify dev up' to automatically pass --password, --store, and --nodelete
elif [[ "$1" == "dev" && "$2" == "up" ]]; then
    echo "Running 'shopify dev up' with additional parameters..."
    /usr/bin/shopify-original dev --password="$SHOPIFY_ACCESS_TOKEN" --store="$SHOPIFY_STORE" --nodelete "${@:3}"

# Modify 'shopify theme list' to add --password and --store if no additional parameters are given
elif [[ "$1" == "theme" && "$2" == "list" ]]; then
    if [[ $# -eq 2 ]]; then
        echo "Running 'shopify theme list' with additional parameters..."
        /usr/bin/shopify-original theme list --password="$SHOPIFY_ACCESS_TOKEN" --store="$SHOPIFY_STORE"
    else
        # Forward the original command with all arguments if parameters are provided
        /usr/bin/shopify-original "$@"
    fi

else
    # Forward all other commands to the actual Shopify CLI
    /usr/bin/shopify-original "$@"
fi

