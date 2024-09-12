# Dockerfile

# Use an official Ruby image with the desired Ruby version
FROM ruby:3.1

# Set build arguments for user ID and group ID
ARG USER_ID
ARG GROUP_ID

# Create a group and user matching the host USER_ID and GROUP_ID to avoid permission issues
RUN groupadd -g $GROUP_ID shopifygroup && \
    useradd -l -u $USER_ID -g shopifygroup -m shopifyuser

# Install dependencies: curl, git, Node.js, npm
RUN apt-get update && apt-get install -y \
    curl git build-essential

# Set up Node.js version 18 using NodeSource repository
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs


# Install Shopify CLI globally using npm
RUN npm install -g @shopify/cli@latest

# Install xdg-utils for opening URLs
RUN apt-get update && apt-get install -y xdg-utils


# Create the /shopify directory with correct permissions
RUN mkdir -p /shopify/theme && chown -R shopifyuser:shopifygroup /shopify

# Set the working directory
WORKDIR /shopify/theme

RUN ls -altr /shopify

# Verify installations
RUN node -v && npm -v && ruby -v && shopify version && xdg-open --version

# Modify permissions during the build process
RUN chown -R shopifyuser:shopifygroup /usr/lib/node_modules/@shopify/cli/dist/assets/cli-ruby

# Copy the entrypoint script and wrapper script
COPY ./assets/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./assets/shopify_wrapper.sh /usr/bin/shopify_wrapper.sh

# Make the script executable
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/bin/shopify_wrapper.sh

# Replace the original shopify command with the wrapper
RUN mv /usr/bin/shopify /usr/bin/shopify-original && \
    ln -s /usr/bin/shopify_wrapper.sh /usr/bin/shopify

# Switch to the created user
USER shopifyuser

# Default command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
