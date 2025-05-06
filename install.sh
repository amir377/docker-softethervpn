#!/bin/bash

prompt_user() {
    local prompt_text="$1"
    local default_value="$2"
    read -p "$prompt_text (Default: $default_value): " input
    echo "${input:-$default_value}"
}

# Prompt user for VPN setup
container_name=$(prompt_user "Enter the container name" "softether-openvpn")
network_name=$(prompt_user "Enter the network name" "general")
vpn_psk=$(prompt_user "Enter VPN Pre-Shared Key (PSK)" "123456789")
vpn_users=$(prompt_user "Enter VPN users (format: user:password)" "admin:admin")
vpn_server_pw=$(prompt_user "Enter Server Admin password" "secretpass")
vpn_hub_pw=$(prompt_user "Enter Hub Admin password" "secretpass")

# Create .env file
echo "Creating .env file for VPN setup..."
cat > .env <<EOL
CONTAINER_NAME=$container_name
NETWORK_NAME=$network_name
VPN_PSK=$vpn_psk
VPN_USERS=$vpn_users
VPN_SERVER_PASSWORD=$vpn_server_pw
VPN_HUB_PASSWORD=$vpn_hub_pw
EOL
echo ".env file created."

# Check Docker and Compose
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create Docker network
echo "Creating Docker network $network_name if not exists..."
docker network create $network_name || echo "Network already exists."

# Generate docker-compose.yaml
if [ -f "docker-compose.example.yaml" ]; then
    echo "Generating docker-compose.yaml from template..."
    envsubst < docker-compose.example.yaml > docker-compose.yaml
else
    echo "Template file docker-compose.example.yaml not found."
    exit 1
fi

# Run Docker Compose
echo "Launching VPN container..."
if docker-compose up -d --build; then
    echo "VPN container started successfully."
else
    echo "Failed to start VPN container. Fetching logs..."
    docker-compose logs
fi