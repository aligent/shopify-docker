# Aligent Shopify Theme Development Template

**Version**: (beta) 1.0  

## Description

Docker image for running the shopify-cli command without requiring it to be installed locally. It includes setup script, few custom shopify commands that simplifies working with Shopify themes via the shopify_wrapper, and yml file for integrating with Bitbucket Pipelines. 

## Limitations

Currently, this setup only supports Bitbucket Pipelines. If the client's repository is hosted on platforms like GitHub, GitLab, or others, the deployment pipeline functionality will not be available and would need to be configured separately.

## File Structure
```bash
.
├── assets
│   ├── entrypoint.sh
│   └── shopify_wrapper.sh
├── docker-compose.yml
├── Dockerfile
├── README.md
└── set-up.sh
```

## File Descriptions

- assets/

    - **entrypoint.sh**: This script is the entrypoint for the Docker container. It initializes the environment, sets the correct permissions, and pulls the Shopify theme using the specified credentials and configurations. It also handles logging and error management during startup.
    - **shopify_wrapper.sh**: A wrapper script for the Shopify CLI that overrides certain commands to enforce specific behavior, such as preventing accidental theme pushes and appending required parameters to shopify dev up commands.
- **docker-compose.yml**: Defines the Docker Compose configuration for the project, specifying services, environment variables, volumes, and other settings needed to run the Shopify CLI within a containerized environment. It facilitates easy orchestration and management of the container setup.

- **Dockerfile**: Contains instructions to build the Docker image for the project. It sets up the environment by installing necessary dependencies, copying scripts, configuring permissions, and setting the appropriate user context for running Shopify CLI commands.

- **README.md**: Provides an overview of the project, including setup instructions, usage guidelines, and other relevant documentation to help users understand and work with the project effectively.

- **set-up.sh**: A setup script that initializes environment variables, prompts the user for required configuration values (like Shopify store URL, theme ID, and access token), and sets up the local environment for running Docker Compose commands. It ensures that the necessary variables are exported and available for the Docker environment.



## Instructions

### Step 1: Create a New Dev/Client Bitbucket Repository

Create a new Bitbucket repository for the Shopify theme development.

### Step 2: Download this repo.

Navigate to the newly created repository and run the following command so it will not include the repository meta-data.

```bash
mkdir temp-clone && cd temp-clone && git init && git remote add origin git@github.com:aligent/shopify-dev-template.git && git config core.sparseCheckout true && echo "/*" > .git/info/sparse-checkout && git pull --depth=1 origin main && mv * .. && cd .. && rm -rf temp-clone

```

### Step 3: Set Up the Development Environment Variables.

Run the following command to initialize the development environment variables and create the themes folder:

```bash
source set-up.sh
```

Ensure that you use source to execute the script so that environment variables are set correctly in your current shell session.

### Step 4: Build the Docker Image

Build the Docker image using Docker Compose to ensure all dependencies and configurations are properly set up:

```bash
docker-compose build --no-cache
```

### Step 5: Start the Docker Services 

Use Docker Compose to start the services defined in docker-compose.yml:

```bash
docker-compose up -d
```

The -d flag runs the containers in detached mode.

### Step 6: (OPTIONAL) Check the Logs

To monitor the live output of the shopify theme pull command and other processes within the container, you can follow the logs:

```bash
docker-compose logs -f shopify-cli
```

## Additional Notes

### Custom Shopify commands

Our custom Shopify wrapper provides simplified and automated versions of commonly used Shopify CLI commands to streamline your workflow:

- ```shopify theme pull``` When run without any arguments, this command automatically uses the store URL, access token, and theme ID specified during the setup process, saving you time and ensuring consistency. If you need to provide specific arguments, the original Shopify theme pull functionality is still available by including them explicitly in the command.

- ```shopify theme dev up``` This is a shorthand command for running shopify theme dev with predefined arguments: --password="$SHOPIFY_ACCESS_TOKEN", --store="$SHOPIFY_STORE", and --nodelete. It simplifies starting the development server by automatically feeding in the required authentication and store details.

- ```shopify theme list``` Lists all available themes and their details for your Shopify store. This command helps you quickly view and manage your themes without needing additional parameters.

- ```shopify theme push``` This command is DISABLED in the development environment to prevent themes from being pushed directly, ensuring that all deployments go through the designated deployment pipeline for better version control and consistency.

- ```shopify show store-config``` Displays the current environment variables related to your Shopify store configuration. This command outputs the values for SHOPIFY_STORE, THEME_ID, and SHOPIFY_ACCESS_TOKEN, allowing you to quickly review the current setup without opening configuration files manually.

- ```shopify edit store-config``` Allows you to update the environment variables for your Shopify store configuration directly from the CLI. When this command is run, it prompts you to enter new values for SHOPIFY_STORE, THEME_ID, and SHOPIFY_ACCESS_TOKEN. If you leave the input blank, the current value is retained. The updates are saved to the local.env file in the Docker container to ensure they persist across sessions.

These custom commands are designed to improve efficiency and enforce best practices while working with Shopify themes in your development environment.


### Stopping/Starting the Docker Services

When you're done, you can stop the running Docker services:
```bash
docker-compose stop
docker-compose start
```

### Access the Shopify CLI

To interact with the Shopify CLI within the running container, you can execute commands directly:

```bash
# Access the container's shell
docker exec -it shopify-cli-container /bin/bash

# Run Shopify CLI commands inside the container
shopify theme pull --store="$SHOPIFY_STORE" --theme="$THEME_ID" --password="$SHOPIFY_ACCESS_TOKEN"
```

## Author

**Author**: Aaron Medina (aaron.medina@aligent.com.au)