#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Redirect all output to a log file
exec > setup.log 2>&1

# Variables (preferably passed as environment variables or Terraform variables)
SPLUNK_PASSWORD="${SPLUNK_PASSWORD_ENV:-changemeAfter123}"  # Splunk admin password
SPLUNK_HEC_TOKEN_NAME="k8s_token"                           # Desired HEC token name
SPLUNK_HEC_TOKEN_DESC="HEC Token via Terraform Script"      # Description for HEC token
SPLUNK_INDEXES=("k8s_events" "k8s_metrics")                 # List of indexes to create

# Update package lists
echo "Updating package lists..."
sudo apt-get update -y

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt-get install docker.io -y
else
    echo "Docker is already installed."
fi

# Add the current user to the Docker group if not already a member
if groups $USER | grep &>/dev/null '\bdocker\b'; then
    echo "User $USER is already in the docker group."
else
    echo "Adding user to Docker group..."
    sudo usermod -aG docker $USER
    echo "Please log out and log back in for group changes to take effect."
fi

# Note: 'newgrp docker' has no effect in non-interactive shells
# Users need to log out and back in for group changes to take effect
# Alternatively, use 'sudo' for Docker commands

echo "Docker installation and configuration complete."

echo "Installing AZ CLI................................"

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az upgrade
sudo apt-get update && sudo apt-get upgrade

echo "AZ CLI Installed."


echo "Installing kubectl ................."

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list 
sudo apt-get update
sudo apt-get install -y kubectl

echo "kubectl installation completed."

echo "Installing helm ............."

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

echo "helm installed."


# Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo apt-get install docker-compose -y
    # Alternatively, install the latest version via pip or download from GitHub
else
    echo "Docker Compose is already installed."
fi

# Verify Docker Compose installation
docker-compose --version

echo "Docker Compose installation complete."

echo "Setting up Splunk..."

# Pull the latest Splunk image
echo "Pulling Splunk Docker image..."
sudo docker pull splunk/splunk:latest

# Run Splunk container if not already running
if [ "$(sudo docker ps -q -f name=splunk)" ]; then
    echo "Splunk container is already running."
else
    echo "Running Splunk Docker container..."
    sudo docker run -d \
      -p 8000:8000 \
      -p 9997:9997 \
      -p 8088:8088 \
      -p 8089:8089 \
      -e "SPLUNK_START_ARGS=--accept-license" \
      -e "SPLUNK_PASSWORD=${SPLUNK_PASSWORD}" \
      --name splunk \
      splunk/splunk:latest
fi

# Function to check if Splunk is up by querying the REST API
check_splunk() {
    # Attempt to get Splunk's REST API version
    curl -k -u admin:"${SPLUNK_PASSWORD}" https://localhost:8089/services/server/info > /dev/null 2>&1
}

# Wait until Splunk is up
echo "Waiting for Splunk to initialize..."
MAX_RETRIES=30
RETRY_COUNT=0
until check_splunk; do
    if [ ${RETRY_COUNT} -ge ${MAX_RETRIES} ]; then
        echo "Splunk did not initialize within expected time."
        exit 1
    fi
    echo "Splunk is not ready yet. Retrying in 10 seconds..."
    sleep 10
    RETRY_COUNT=$((RETRY_COUNT+1))
done
echo "Splunk is up and running."

# Function to execute Splunk CLI commands inside the Docker container as 'splunk' user
splunk_exec() {
    local cmd="$1"
    sudo docker exec -u splunk splunk /opt/splunk/bin/splunk ${cmd} -auth admin:"${SPLUNK_PASSWORD}"
}

# Create Splunk indexes
echo "Creating Splunk indexes..."
for index in "${SPLUNK_INDEXES[@]}"; do
    echo "Creating index: ${index}"
    splunk_exec "add index ${index}"
done
echo "Splunk indexes creation complete."

# Enable HTTP Event Collector (HEC)
echo "Enabling HTTP Event Collector (HEC)..."
sudo docker exec splunk /opt/splunk/bin/splunk enable listen 8088 -auth admin:"${SPLUNK_PASSWORD}"

# Function to create HEC token via Splunk REST API
create_hec_token() {
    local token_name="$1"
    local token_desc="$2"
    # Define the indexes associated with this HEC token
    local token_indexes="$3"  # Comma-separated list of indexes

    echo "Creating HEC token: ${token_name}"

    # Use curl to interact with Splunk's REST API
    # Create the HEC token
    response=$(curl -k -u admin:"${SPLUNK_PASSWORD}" \
        https://localhost:8089/services/data/inputs/http -d name="${token_name}" \
        -d index="${token_indexes}" -d disabled=0 -d default=true -d description="${token_desc}")

    # Check if the token was created successfully
    if echo "$response" | grep -q "content"; then
        echo "HEC token '${token_name}' created successfully."
    else
        echo "Failed to create HEC token '${token_name}'. Response:"
        echo "$response"
        exit 1
    fi
}

# Create HEC token
create_hec_token "${SPLUNK_HEC_TOKEN_NAME}" "${SPLUNK_HEC_TOKEN_DESC}" "$(IFS=,; echo "${SPLUNK_INDEXES[*]}")"

echo "HEC token creation complete."

echo "Splunk setup complete."
