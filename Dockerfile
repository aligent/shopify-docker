# Use an official Ruby image with the desired Ruby version
FROM ruby:3.1

# Install dependencies: curl, git, Node.js, npm
RUN apt-get update && apt-get install -y \
    curl git build-essential

# Set up Node.js version 18 using NodeSource repository
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Ensure npm is installed correctly by reinstalling npm explicitly if needed
RUN apt-get install -y npm

# Verify Node.js and npm installation
RUN node -v && npm -v

# Install Shopify CLI globally using npm
RUN npm install -g @shopify/cli@latest

# Verify Shopify CLI installation
RUN shopify version

# Default command to keep the container running in an interactive shell
CMD ["bash"]
