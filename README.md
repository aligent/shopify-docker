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
├── bitbucket-pipelines.yml
├── docker-compose.yml
├── Dockerfile
├── README.md
└── set-up.sh
```

## File Descriptions

- assets/

    - **entrypoint.sh**: This script is the entrypoint for the Docker container. It initializes the environment, sets the correct permissions, and pulls the Shopify theme using the specified credentials and configurations. It also handles logging and error management during startup.
    - **shopify_wrapper.sh**: A wrapper script for the Shopify CLI that overrides certain commands to enforce specific behavior, such as preventing accidental theme pushes and appending required parameters to shopify dev up commands.
- **bitbucket-pipeline.yml**: Template bitbucket yml
- **docker-compose.yml**: Defines the Docker Compose configuration for the project, specifying services, environment variables, volumes, and other settings needed to run the Shopify CLI within a containerized environment. It facilitates easy orchestration and management of the container setup.

- **Dockerfile**: Contains instructions to build the Docker image for the project. It sets up the environment by installing necessary dependencies, copying scripts, configuring permissions, and setting the appropriate user context for running Shopify CLI commands.

- **README.md**: Provides an overview of the project, including setup instructions, usage guidelines, and other relevant documentation to help users understand and work with the project effectively.

- **set-up.sh**: A setup script that initializes environment variables, prompts the user for required configuration values (like Shopify store URL, theme ID, and access token), and sets up the local environment for running Docker Compose commands. It ensures that the necessary variables are exported and available for the Docker environment and adding local development files to .gitignore.



## Instructions

### Step 1: Create NEW folder for your shopify development.

Create a new workspace for your shopify development.

### Step 2: Download this repo.

Navigate to the repository and run the following command so it will not include the repository meta-data and README.md.

```bash
git clone git@github.com:aligent/shopify-docker.git
```
### Step 3: Add aliases to you bash profile

Add the following line to your ```~/.bash_aliases``` (or .bash_profile, .bashrc, etc) file to be able to run things easily

```bash
cat << 'EOF' >> ~/.bashrc
shopify() {
    if [[ $1 == 'env' && $2 == 'init' ]]; then
        docker-compose build --no-cache && docker-compose up -d 
    elif [[ $1 == 'env' && $2 == 'start' ]]; then
        docker-compose start
    elif [[ $1 == 'env' && $2 == 'stop' ]]; then
        docker-compose stop
    else
        docker exec -it shopify-cli-container shopify "$@"
    fi
}
EOF
```

Ensure that you ```source``` your profile to execute the script so that environment variables are set correctly in your current shell session.

```bash
source ~/.bashrc
```

### Step 4: Set Up the Development Environment Variables.

Run the command and follow the prompt to initialize the development environment:

```bash
source set-up.sh
```
This will set the environment variables and create the ```theme``` folder

### Step 5: Initialise Development Environment

```bash
shopify env init
```

### Step 6: Check if Shopify is running

Run the shopify version command:

```bash
shopify --version
```

You now have a running shopify local development environment .

## Additional Notes

### Custom Shopify commands

Our custom Shopify wrapper provides simplified and automated versions of commonly used Shopify CLI commands to streamline your workflow:

- ```shopify theme pull``` When run without any arguments, this command automatically uses the SHOPIFY_STORE, SHOPIFY_ACCESS_TOKEN, and THEME_ID in the environment variables specified during the setup process, saving you time and ensuring consistency. If you need to provide specific arguments, the original Shopify theme pull functionality is still available by including them explicitly in the command.

- ```shopify theme dev up``` This is a shorthand command for running shopify theme dev with predefined arguments: ```--password=$SHOPIFY_ACCESS_TOKEN```, ```--store=$SHOPIFY_STORE```, and ```--nodelete```. It simplifies starting the development server by automatically feeding in the required authentication and store details.

- ```shopify theme list``` Lists all available themes and their details for your Shopify store. This command helps you quickly view and manage your themes without needing additional parameters.

- ```shopify theme push``` This command is **DISABLED** in the development environment to prevent themes from being pushed directly, ensuring that all deployments go through the designated deployment pipeline for better version control and consistency.

- ```shopify show store-config``` Displays the current environment variables related to your Shopify store configuration. This command outputs the values for SHOPIFY_STORE, THEME_ID, and SHOPIFY_ACCESS_TOKEN, allowing you to quickly review the current setup without opening configuration files manually.

- ```shopify edit store-config``` Allows you to update the environment variables for your Shopify store configuration directly from the CLI. When this command is run, it prompts you to enter new values for SHOPIFY_STORE, THEME_ID, and SHOPIFY_ACCESS_TOKEN. If you leave the input blank, the current value is retained. The updates are saved to the local.env file in the Docker container to ensure they persist across sessions.

These custom commands are designed to improve efficiency and enforce best practices while working with Shopify themes in your development environment.


### Managing your Shopify local environment.

You can start/stop your Shopify environment using these commands:
```bash
shopify env stop
shopify env start
```

## Configuring Shopify Theme Bitbucket Pipeline

### Set Repository Variables
- SHOPIFY_STORE
- SHOPIFY_ACCESS_TOKEN
- FAIL_LEVEL
```bash
<options: crash|error|suggestion|style|warning|info>
```

### Set Deployments Variable

Staging
- THEME_ID

- ASCII_LABEL

"STAGING"
```bash
  _____ _______       _____ _____ _   _  _____ \n / ____|__   __|/\   / ____|_   _| \ | |/ ____|\n| (___    | |  /  \ | |  __  | | |  \| | |  __ \n \___ \   | | / /\ \| | |_ | | | | .   | | |_ |\n ____) |  | |/ ____ \ |__| |_| |_| |\  | |__| |\n|_____/   |_/_/    \_\_____|_____|_| \_|\_____|\n
  ```

- THEME_PUSH_ARGS
```--verbose --nodelete
```

Production
- THEME_ID

- ASCII_LABEL

"PRODUCTION"
```bash
 _____  _____   ____  _____  _    _  _____ _______ _____ ____  _   _ \n|  __ \|  __ \ / __ \|  __ \| |  | |/ ____|__   __|_   _/ __ \| \ | |\n| |__) | |__) | |  | | |  | | |  | | |       | |    | || |  | |  \| |\n|  ___/|  _  /| |  | | |  | | |  | | |       | |    | || |  | | .   |\n| |    | | \ \| |__| | |__| | |__| | |____   | |   _| || |__| | |\  |\n|_|    |_|  \_|\____/|_____/ \____/ \_____|  |_|  |_____\____/|_| \_|\n
 ```

- THEME_PUSH_ARGS
```bash
--verbose --allow-live
```

## Author

**Author**: Aaron Medina (aaron.medina@aligent.com.au)