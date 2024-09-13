# Dockerfile

# Use an official Ruby image with the desired Ruby version
FROM ruby:3.1

# Install dependencies: curl, git, Node.js, npm
RUN apt-get update && apt-get install -y \
    curl git build-essential

# Set up Node.js version 18 using NodeSource repository
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install Shopify CLI globally using npm
RUN npm install -g @shopify/cli@latest

# Verify installations
RUN node -v && npm -v && ruby -v && shopify version 

# Default command to keep the container running in an interactive shell
CMD ["bash"]
