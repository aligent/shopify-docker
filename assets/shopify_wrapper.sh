#!/bin/bash


# Load environment variables from the local.env file inside the container
if [ -f "/shopify/local.env" ]; then
    export $(grep -v '^#' /shopify/local.env | xargs)
else
    echo "Error: local.env file not found. Please run 'shopify env init' to create it."
    exit 1
fi

# Block 'shopify theme push' command
if [[ "$1" == "theme" && "$2" == "push" ]]; then
    echo "Error: 'shopify theme push' command is disabled in this environment."
    exit 0

# Modify 'shopify dev up' to automatically pass --password, --store, and --nodelete
elif [[ "$1" == "theme" && "$2" == "dev" && "$3" == "up" ]]; then
    echo "Running 'shopify theme dev' with additional parameters..."
    /usr/bin/shopify-original theme dev --password="$SHOPIFY_ACCESS_TOKEN" --store="$SHOPIFY_STORE" --nodelete

# Modify 'shopify theme list' to add --password and --store if no additional parameters are given
elif [[ "$1" == "theme" && "$2" == "list" ]]; then
    if [[ $# -eq 2 ]]; then
        echo "Running 'shopify theme list' with additional parameters..."
        /usr/bin/shopify-original theme list --password="$SHOPIFY_ACCESS_TOKEN" --store="$SHOPIFY_STORE"
    else
        # Forward the original command with all arguments if parameters are provided
        /usr/bin/shopify-original "$@"
    fi

#Modify 'shopify theme pull' to add --password and --store if no additional parameters are given
elif [[ "$1" == "theme" && "$2" == "pull" ]]; then
    if [[ $# -eq 2 ]]; then
        echo "Running 'shopify theme pull' with default parameters."
        /usr/bin/shopify-original theme pull --password="$SHOPIFY_ACCESS_TOKEN" --store="$SHOPIFY_STORE"
    else
        # Forward the original command with all arguments if parameters are provided
        /usr/bin/shopify-original "$@"
    fi

# Custom command to show current environment variables
elif [[ "$1" == "show" && "$2" == "store-config" ]]; then
    echo -e "\nCurrent environment variables:"
    echo -e "SHOPIFY_STORE: $SHOPIFY_STORE"
    echo -e "THEME_ID: $THEME_ID"
    echo -e "SHOPIFY_ACCESS: $SHOPIFY_ACCESS_TOKEN\n"

    echo -e "To edit these values, run: shopify edit store-config\n"

# Custom command to edit and update environment variables
elif [[ "$1" == "edit" && "$2" == "store-config" ]]; then
    echo -e "\nUpdating environment variables for store configuration:"
    
    # Function to update a key-value pair in the local.env file
    update_env() {
        local key=$1
        local value=$2
        # Check if the key exists in the file; if yes, update it, otherwise add it
        if grep -q "^${key}=" "/shopify/local.env"; then
            sed -i.bak "s|^${key}=.*|${key}=${value}|" "/shopify/local.env"
        else
            echo "${key}=${value}" >> "/shopify/local.env"
        fi
    }

    # Prompt the user for new values
    read -p "Enter Shopify Store URL (current: $SHOPIFY_STORE): " new_store
    if [ ! -z "$new_store" ]; then 
        SHOPIFY_STORE="$new_store"
        update_env "SHOPIFY_STORE" "$SHOPIFY_STORE"
    fi

    read -p "Enter Theme ID (current: $THEME_ID): " new_theme_id
    if [ ! -z "$new_theme_id" ]; then 
        THEME_ID="$new_theme_id"
        update_env "THEME_ID" "$THEME_ID"
    fi

    read -p "Enter Shopify Access Token (current: $SHOPIFY_ACCESS_TOKEN): " new_access_token
    if [ ! -z "$new_access_token" ]; then 
        SHOPIFY_ACCESS_TOKEN="$new_access_token"
        update_env "SHOPIFY_ACCESS_TOKEN" "$SHOPIFY_ACCESS_TOKEN"
    fi

    echo -e "\nEnvironment variables have been updated successfully in local.env."

else
    # Forward all other commands to the actual Shopify CLI
    /usr/bin/shopify-original "$@"
fi

