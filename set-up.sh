#!/bin/bash

# Define the path to the local.env file
ENV_FILE="./local.env"

# Function to prompt for environment variables
prompt_for_values() {
    read -p "Enter Shopify Store URL: " SHOPIFY_STORE
    read -p "Enter Theme ID: " THEME_ID
    read -p "Enter Shopify Access Token: " SHOPIFY_ACCESS_TOKEN

    # Write environment variables to local.env
    cat <<EOF > $ENV_FILE
SHOPIFY_STORE=$SHOPIFY_STORE
THEME_ID=$THEME_ID
SHOPIFY_ACCESS_TOKEN=$SHOPIFY_ACCESS_TOKEN
EOF
    echo "Environment variables have been set successfully in local.env."
}

# Function to load existing values from local.env
load_existing_values() {
    # Load existing values from local.env
    source $ENV_FILE
    echo "Existing environment variables found:"
    echo "SHOPIFY_STORE: $SHOPIFY_STORE"
    echo "THEME_ID: $THEME_ID"
    echo "SHOPIFY_ACCESS_TOKEN: $SHOPIFY_ACCESS_TOKEN"
}

# Check if local.env file exists
if [ -f "$ENV_FILE" ]; then
    # Load and display existing values
    load_existing_values

    # Ask user if they want to use the existing values or enter new ones
    read -p "Do you want to use the existing values? (yes to confirm, no to re-enter): " confirm
    if [[ "$confirm" != "yes" ]]; then
        prompt_for_values
    else
        echo "Using existing values from local.env."
    fi
else
    # Prompt for new values if local.env does not exist
    prompt_for_values
fi

# Check if .gitignore exists, if not, create it
if [ ! -f ".gitignore" ]; then
    touch .gitignore
fi

# If theme folder does not exist, create it
if [ ! -d "theme" ]; then
    mkdir theme
    echo "Created 'theme' directory to store theme files."
fi

# Add local.env to .gitignore if not already there
if ! grep -qx "local.env" .gitignore; then
    echo "local.env" >> .gitignore
    echo "Added 'local.env' to .gitignore to prevent it from being tracked by Git."
else
    echo "'local.env' is already listed in .gitignore."
fi

# Check and set environment variables for USER_ID and GROUP_ID
# Only set them if they are not already set and readonly
if [ -z "$USER_ID" ]; then
    export USER_ID=$(id -u)
    echo "USER_ID: $USER_ID"
else
    echo "USER_ID is already set: $USER_ID"
fi

if [ -z "$GROUP_ID" ]; then
    export GROUP_ID=$(id -g)
    echo "GROUP_ID: $GROUP_ID"
else
    echo "GROUP_ID is already set: $GROUP_ID"
fi

# Define the alias command
ALIAS_COMMAND='alias shopify="docker exec -it shopify-cli-container shopify"'

# Check if the alias already exists in the shell profile
if ! grep -Fxq "$ALIAS_COMMAND" ~/.bashrc && ! grep -Fxq "$ALIAS_COMMAND" ~/.zshrc; then
    # Append the alias to the appropriate shell profile
    if [[ $SHELL == *"bash"* ]]; then
        echo "$ALIAS_COMMAND" >> ~/.bashrc
        source ~/.bashrc
    elif [[ $SHELL == *"zsh"* ]]; then
        echo "$ALIAS_COMMAND" >> ~/.zshrc
        source ~/.zshrc
    else
        echo "Unsupported shell. Please manually add the alias to your shell profile."
    fi
    echo "Alias 'shopify' added and shell profile reloaded."
else
    echo "Alias 'shopify' already exists in your shell profile."
fi

# Inform the user to rebuild and restart Docker Compose services
echo -e "\nPlease rebuild and restart Docker Compose services with the following commands:"
echo -e "docker-compose build --no-cache"
echo -e "docker-compose up -d"
