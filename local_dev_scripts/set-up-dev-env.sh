#!/bin/bash

# Get the directory of the script itself
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the path to the local.env file relative to the script's directory
ENV_FILE="$SCRIPT_DIR/../local.env"
GITIGNORE_FILE="$SCRIPT_DIR/../.gitignore"  # Define path to the .gitignore file

# Check if the local.env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "Error: local.env file not found at $ENV_FILE"
    exit 1
fi

# Function to update a key-value pair in the local.env file
update_env() {
    local key=$1
    local value=$2
    # Check if the key exists in the file; if yes, update it, otherwise add it
    if grep -q "^${key}=" "$ENV_FILE"; then
        sed -i.bak "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
    else
        echo "${key}=${value}" >> "$ENV_FILE"
    fi
}

# Function to prompt for values and update variables
prompt_for_values() {
    echo -e "\nPlease enter the following values (leave blank to keep current values):"

    read -p "IMAGE_NAME (current: $(grep '^IMAGE_NAME=' $ENV_FILE | cut -d '=' -f2)): " image_name
    if [ ! -z "$image_name" ]; then update_env "IMAGE_NAME" "$image_name"; fi

    read -p "CONTAINER_NAME (current: $(grep '^CONTAINER_NAME=' $ENV_FILE | cut -d '=' -f2)): " container_name
    if [ ! -z "$container_name" ]; then update_env "CONTAINER_NAME" "$container_name"; fi

    read -p "SHOPIFY_STORE (current: $(grep '^SHOPIFY_STORE=' $ENV_FILE | cut -d '=' -f2)): " shopify_store
    if [ ! -z "$shopify_store" ]; then update_env "SHOPIFY_STORE" "$shopify_store"; fi

    read -p "THEME_ID (current: $(grep '^THEME_ID=' $ENV_FILE | cut -d '=' -f2)): " theme_id
    if [ ! -z "$theme_id" ]; then update_env "THEME_ID" "$theme_id"; fi

    read -p "FAIL_LEVEL [crash|error|suggestion|style|warning|info] (current: $(grep '^FAIL_LEVEL=' $ENV_FILE | cut -d '=' -f2)): " fail_level
    if [ ! -z "$fail_level" ]; then update_env "FAIL_LEVEL" "$fail_level"; fi

    read -p "SHOPIFY_ACCESS_TOKEN (current: $(grep '^SHOPIFY_ACCESS_TOKEN=' $ENV_FILE | cut -d '=' -f2)): " shopify_access_token
    if [ ! -z "$shopify_access_token" ]; then update_env "SHOPIFY_ACCESS_TOKEN" "$shopify_access_token"; fi

    # Set INITIATED to true
    update_env "INITIATED" "true"
}

# Function to verify the values in the local.env file
verify_values() {
    echo -e "\nPlease review the updated values in the local.env file:"
    cat "$ENV_FILE"
    echo -e "\n"
}

# Function to write or append to the .gitignore file
write_gitignore() {
    echo -e "\nUpdating .gitignore file..."

    # Define ignore patterns
    IGNORE_PATTERNS=(
        "local.env"
        "local.env.bak"
    )

    # Check if .gitignore file exists
    if [ ! -f "$GITIGNORE_FILE" ]; then
        echo ".gitignore file does not exist. Creating a new one."
        touch "$GITIGNORE_FILE"
    fi

    # Append patterns to .gitignore if they are not already present
    for pattern in "${IGNORE_PATTERNS[@]}"; do
        if ! grep -qx "$pattern" "$GITIGNORE_FILE"; then
            echo "$pattern" >> "$GITIGNORE_FILE"
            echo "Added '$pattern' to .gitignore."
        else
            echo "'$pattern' is already in .gitignore."
        fi
    done

    echo -e ".gitignore has been updated.\n"
}

create_theme_folder() {
    mkdir -p theme
    echo -e "\nCreated 'theme' folder.\n"
}

# Main script loop to allow verification and retry
while true; do
    # Prompt user to enter or update values
    prompt_for_values

    # Display the updated values for verification
    verify_values

    # Ask the user if the values are correct
    read -p "Are these values correct? (yes to confirm, no to retry): " confirmation

    # Check user's response
    if [[ "$confirmation" == "yes" ]]; then
        echo -e "\nEnvironment variables updated successfully in $ENV_FILE."
        break
    else
        echo -e "\nLet's try updating the values again."
    fi
done

# Write to the .gitignore file
write_gitignore

#Create the theme folder
create_theme_folder