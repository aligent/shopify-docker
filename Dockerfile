# Dockerfile

# Use an official Ruby image with the desired Ruby version
FROM aligent/shopify-cli:latest

# Set build arguments for user ID and group ID
ARG USER_ID
ARG GROUP_ID

RUN groupadd -g "$GROUP_ID" shopifygroup && \
    useradd -l -u "$USER_ID" -g shopifygroup -m shopifyuser 2>/dev/null

# Install xdg-utils for opening URLs
RUN apt-get update && apt-get install -y xdg-utils

# Verify installations
RUN node -v && npm -v && ruby -v && shopify version && xdg-open --version

# Create the /shopify directory with correct permissions
RUN mkdir -p /shopify/theme

# Copy the entrypoint script and wrapper script
COPY ./assets/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./assets/shopify_wrapper.sh /usr/bin/shopify_wrapper.sh

# Make the script executable
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/bin/shopify_wrapper.sh

# Replace the original shopify command with the wrapper
RUN mv /usr/bin/shopify /usr/bin/shopify-original && \
    ln -s /usr/bin/shopify_wrapper.sh /usr/bin/shopify

USER shopifyuser

# Default command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]