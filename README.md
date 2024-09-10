# Aligent Shopify Theme Development Tools

**Version**: (beta) 1.0  
**Author**: Aaron Medina (aaron.medina@aligent.com.au)

## Description

This repository contains scripts and tools designed to set up and manage a Shopify theme development environment for clients. It includes various utilities for configuring a local development setup, working with Shopify themes, and integrating with Bitbucket Pipelines for CI/CD processes. These tools streamline the development workflow by providing a Docker-based environment, command-line utilities for interacting with Shopify themes, and scripts to automate repetitive tasks.

## File Structure

```bash
shopify-theme-development-tools
├── bitbucket-pipelines.yml
├── Dockerfile
├── download.sh
├── local_dev_scripts
│   ├── set-up-dev-env.sh
│   ├── shopify-build.sh
│   ├── shopify-dev.sh
│   ├── shopify-get-theme-info.sh
│   ├── shopify-run.sh
│   ├── shopify-stop.sh
│   ├── shopify-test-connection
│   ├── shopify-theme-check.sh
│   ├── shopify-theme-pull.sh
│   └── utils.sh
├── local.env
└── README.md
```

## File Descriptions

- **bitbucket-pipelines.yml**: Contains the configuration for Bitbucket Pipelines, used for automating CI/CD processes.
- **Dockerfile**: Defines the Docker image configuration for the local development environment.
- **download.sh**: Script to download all necessary files for setting up the Shopify theme development tools.
- **local_dev_scripts**: Directory containing scripts to assist developers during the implementation process.
  - **set-up-dev-env.sh**: Initializes the development environment, setting up the `local.env` file with required variables.
  - **shopify-build.sh**: Builds the Docker image used for local development.
  - **shopify-dev.sh**: Runs the theme locally in development mode.
  - **shopify-get-theme-info.sh**: Fetches information about the available themes from the Shopify store.
  - **shopify-run.sh**: Starts the Docker container for the local development environment in detached mode.
  - **shopify-stop.sh**: Stops the running Docker container.
  - **shopify-test-connection**: Test the credentials. If valid, it will print a list of your themes.
  - **shopify-theme-check.sh**: Runs Shopify Theme Check for code quality and best practices.
  - **shopify-theme-pull.sh**: Downloads the target Shopify theme into the local development environment.
  - **utils.sh**: Contains utility functions used by other scripts.
- **local.env**: Environment variables file for the local development setup. **Note:** This file should not be committed to the repository for security reasons.
- **README.md**: Documentation file providing setup instructions and descriptions of the repository contents.

## Instructions

### Step 1: Create a New Bitbucket Repository

Create a new Bitbucket repository for the client's Shopify theme.

### Step 2: Download Necessary Files

Navigate to the newly created repository and run the following command to download all necessary files:

```bash
bash <(curl -s https://raw.githubusercontent.com/aaron-medina-aligent/test-shop-repo/main/download.sh)
```

This will also generate a .gitignore file to ensure that sensitive files like local.env are not included in the repository.

### Step 3: Set Up the Development Environment

Run the following command to initialize the development environment:

```bash
bash ./local_dev_scripts/set-up-dev-env.sh
```

You will be prompted to provide the following information:

- IMAGE_NAME (default: shopify-docker-image)
- CONTAINER_NAME (default: shopify-container)
- SHOPIFY_STORE (e.g., mystore.shopify)
- THEME_ID (Use shopify-get-theme-info.sh to retrieve the theme ID if unknown initially)
- FAIL_LEVEL (e.g., crash, error, suggestion, etc.)
- SHOPIFY_ACCESS_TOKEN (Generated from the Theme Access app in Shopify)

### Step 4: Test Shopify Connection

To ensure the configuration is correct, test your connection with Shopify:

```bash
bash ./local_dev_scripts/shopify-test-connection.sh
```

### Step 5: Build the Docker Image

Build the Docker image for your local development environment:
```bash
bash ./local_dev_scripts/shopify-build.sh
```

### Step 6: Run the Docker Container

Start the Docker container in detached mode. This step should be performed every time you want to run your local development environment:

```bash
bash ./local_dev_scripts/shopify-run.sh
```

### Step 7: Pull the Shopify Theme

Download the Shopify theme that you will be working on:

```bash
bash ./local_dev_scripts/shopify-theme-pull.sh
```

The theme files will be downloaded into the theme folder.

### Step 8: Run the Theme locally

To start the local development server for the theme:

```bash
bash ./local_dev_scripts/shopify-dev.sh
```

### Step 9: Check Theme Quality

To perform a theme check for code quality and adherence to Shopify best practices, use the following command:

```bash
bash ./local_dev_scripts/shopify-theme-check.sh
```

### Step 10: Configure Repository Variables

Go to your Bitbucket repository settings and add the following repository variables:

- SHOPIFY_STORE
- SHOPIFY_ACCESS_TOKEN
- FAIL_LEVEL
- DOCKER_HUB_USERNAME
- DOCKER_HUB_PASSWORD

Ensure the "Secured" option is ticked for sensitive information.
The Docker hub credentials are temporary, will be removed once the docker image is moved to a public repo.

### Step 11: Configure Deployment Variables

Configure the following deployment variables under Bitbucket repository settings for each environment:
Staging:
- THEME_ID
- FAIL_LEVEL

Production:

- THEME_ID
- FAIL_LEVEL

These configurations are essential for deploying themes to different environments.

