#!/bin/bash

# Define color variables
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
BOLD='\033[1m'
RESET='\033[0m'

# Function to navigate to the project directory
navigate_to_project() {
  cd "$(dirname "$0")/.." || exit
}

# Function to load environment variables
load_env() {
  set -o allexport
  source .env
  if [ -f .access_token ]; then
    source .access_token
  fi
  set +o allexport
}

# Function to check if a variable is set in the environment
check_variable() {
  local var_name="$1"
  if [ -z "${!var_name}" ]; then
    echo -e "${RED}ERROR${RESET}: $var_name is not set in the .env file."
    exit 1
  fi
}

# Function to check if a Docker container is running
is_container_running() {
  docker ps -q -f name="$1" | grep -q .
}

# Function to start an existing Docker container
start_existing_container() {
  echo -e "Starting existing container '${YELLOW}$1${RESET}'..."
  docker start "$1"
}

# Function to run a new Docker container
run_new_container() {
  echo -e "Running new container '${YELLOW}$1${RESET}' in detached mode..."
  docker run -d \
    --name "$1" \
    --volume "$(pwd):/shopify" \
    -w /shopify/theme \
    --env-file .env \
    --user "$(id -u):$(id -g)" \
    $IMAGE_NAME tail -f /dev/null
}
