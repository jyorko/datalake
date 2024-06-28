# Use the official Alpine image
FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    bash \
    curl \
    tar \
    nodejs \
    npm \
    git \
    libc6-compat

# Create a directory for VS Code Server
RUN mkdir -p /home/vscode-server

# Copy the VS Code Server tarball into the Docker image
COPY vscode_cli_alpine_x64_cli.tar.gz /home/vscode-server/

# Extract the VS Code Server tarball
RUN cd /home/vscode-server && tar -xzf vscode_cli_alpine_x64_cli.tar.gz

# List the contents to determine the correct path
RUN ls /home/vscode-server

# Make the VS Code Server executable (adjust path based on extracted contents)
RUN chmod +x /home/vscode-server/bin/code-server

# Expose the port
EXPOSE 8080

# Set the working directory
WORKDIR /home/vscode-server

# Command to run VS Code Server
CMD ["./bin/code-server", "--host", "0.0.0.0", "--port", "8080"]

