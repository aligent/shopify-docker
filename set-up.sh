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
    echo -e "Environment variables have been set successfully in local.env.\n"
}

# Function to load existing values from local.env
load_existing_values() {
    # Load existing values from local.env
    source $ENV_FILE
    echo -e "Existing environment variables found:"
    echo -e "SHOPIFY_STORE: $SHOPIFY_STORE"
    echo -e "THEME_ID: $THEME_ID"
    echo -e "SHOPIFY_ACCESS_TOKEN: $SHOPIFY_ACCESS_TOKEN\n"
}

# Define a cleanup function
cleanup() {
    echo "An error occurred. Please review the messages above and fix any issues."
    read -p "Press Enter to continue or Ctrl+C to exit."
}

# Set trap for errors (e.g., signal 1, 2, 3, and ERR for any command failure)
trap cleanup 1 2 3 ERR

# Check if local.env file exists
if [ -f "$ENV_FILE" ]; then
    # Load and display existing values
    load_existing_values

    # Ask user if they want to use the existing values or enter new ones
    read -p "Do you want to use the existing values? (yes to confirm, no to re-enter): " confirm
    if [[ "$confirm" != "yes" ]]; then
        prompt_for_values
    else
        echo -e "Using existing values from local.env.\n"
    fi
else
    # Prompt for new values if local.env does not exist
    prompt_for_values
fi

# Prompt for the theme Git repository URL and branch
read -p "Enter the Git repository URL for the theme: " THEME_REPO_URL
read -p "Enter the branch name to clone: " THEME_BRANCH

# If theme folder does not exist, create it
if [ ! -d "theme" ]; then
    mkdir theme
    echo "Created 'theme' directory to store theme files."
fi

# Clone the specified branch of the theme Git repository into the theme folder
echo "Cloning the theme from $THEME_REPO_URL (branch: $THEME_BRANCH) into the 'theme' folder..."
git clone --branch "$THEME_BRANCH" "$THEME_REPO_URL" theme || {
    echo "Failed to clone the repository. Please check the URL and branch name."
}
echo -e "\nTheme successfully cloned into the 'theme' folder."

# Move bitbucket-pipelines.yml into the theme folder if it doesn't exist there
if [ -f "bitbucket-pipelines.yml" ] && [ ! -f "theme/bitbucket-pipelines.yml" ]; then
    mv bitbucket-pipelines.yml theme/
    echo -e "\n Moved 'bitbucket-pipelines.yml' into the 'theme' folder."
elif [ -f "theme/bitbucket-pipelines.yml" ]; then
    echo -e "\n The file 'bitbucket-pipelines.yml' already exists in the 'theme' folder."
else
    echo -e "\n WARNING: 'bitbucket-pipelines.yml' not found in the current directory to move."
fi

# Check and set environment variables for USER_ID and GROUP_ID
echo -e "\nChecking and setting USER_ID and GROUP_ID environment variables:"
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

# Inform the user to rebuild and restart Docker Compose services
echo -e "\nPlease run the command to initialize your dev environment:"
echo -e "shopify env init\n"
