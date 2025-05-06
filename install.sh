#!/bin/bash

# Function to prompt user for input with a default value
prompt_user() {
    local prompt_text="$1"
    local default_value="$2"
    read -p "$prompt_text (Default: $default_value): " input
    echo "${input:-$default_value}"
}

# Prompt user for SoftEther VPN setup details
container_name=$(prompt_user "Enter the container name" "softether-openvpn")
network_name=$(prompt_user "Enter the network name" "general")
vpn_psk=$(prompt_user "Enter the SoftEther VPN psk" "123456789")
vpn_users=$(prompt_user "Enter the SoftEther VPN users" "admin:admin")
vpn_server_password=$(prompt_user "Enter the SoftEther VPN server password" "secretpass")
vpn_hub_password=$(prompt_user "Enter the SoftEther VPN hub password" "secretpass")

# Generate the .env file
echo "Creating .env file for SoftEther VPN setup..."
cat > .env <<EOL
# SoftEther VPN container settings
CONTAINER_NAME=$container_name
NETWORK_NAME=$network_name

# SoftEther VPN credentials
VPN_PSK=$vpn_psk
VPN_USERS=$vpn_users
VPN_SERVER_PASSWORD=$vpn_server_password
VPN_HUB_PASSWORD=$vpn_hub_password
EOL
echo ".env file created successfully."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully."
fi

# Create the network before building the container
echo "Creating Docker network $network_name if it does not already exist..."
docker network create $network_name || echo "Network $network_name already exists. Skipping creation."

# Use docker-compose.example.yaml to create docker-compose.yaml
echo "Generating docker-compose.yaml file from docker-compose.example.yaml..."
if [ -f "docker-compose.example.yaml" ]; then
    sed -e "s/\${CONTAINER_NAME}/$container_name/g" \
        -e "s/\${NETWORK_NAME}/$network_name/g" \
        -e "s/\${PSK}/$vpn_psk/g" \
        -e "s/\${USERS}/$vpn_users/g" \
        -e "s/\${SPW}/$vpn_server_password/g" \
        -e "s/\${HPW}/$vpn_hub_password/g" \
        docker-compose.example.yaml > docker-compose.yaml
    echo "docker-compose.yaml file created successfully."
else
    echo "docker-compose.example.yaml file not found. Please ensure it exists in the current directory."
    exit 1
fi

# Start Docker Compose with build
echo "Starting Docker Compose with --build for SoftEther VPN..."
if docker-compose up -d --build; then
    echo "Checking container status..."
    if [ "$(docker inspect -f '{{.State.Running}}' $container_name)" = "true" ]; then
        echo "SoftEther VPN setup is complete and running. Connecting to the container..."
        docker exec -it $container_name bash
    else
        echo "Container is not running. Fetching logs..."
        docker logs $container_name
    fi
else
    echo "Failed to start Docker Compose. Ensure Docker is running and try again."
    exit 1
fi
