# Use the custom base image with Ruby, Node.js, npm, and Shopify CLI pre-installed
FROM aaronmedinaaligent/shopify-cli-base:latest

# Set build arguments for user ID and group ID
ARG USER_ID
ARG GROUP_ID

# Create a group and user matching the host UID and GID to avoid permission issues
RUN groupadd -g $GROUP_ID shopifygroup && \
    useradd -l -u $USER_ID -g shopifygroup -m shopifyuser

# Create the /theme directory and set the correct permissions
RUN mkdir -p /shopify && chown shopifyuser:shopifygroup /shopify

# Install xdg-utils for opening URLs
RUN apt-get update && apt-get install -y xdg-utils

# Modify permissions during the build process
RUN chown -R shopifyuser:shopifygroup /usr/local/lib/node_modules/@shopify/cli/dist/assets/cli-ruby

# Set the working directory
WORKDIR /shopify

# Switch to the non-root user for security
USER shopifyuser

# Verify installations
RUN node -v && npm -v && ruby -v && bundler -v && shopify version && xdg-open --version

# Default command to keep the container running in an interactive shell
CMD ["bash"]
