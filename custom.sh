#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
SPLUNK_PASSWORD="changemeAfter123"           # Splunk admin password
SPLUNK_HEC_TOKEN_NAME="k8s_token"     # Desired HEC token name
SPLUNK_HEC_TOKEN_DESC="HEC Token via Terraform Script"  # Description for HEC token
SPLUNK_INDEXES=("k8s_events" "k8s_metrics")             # List of indexes to create

# Update package lists
echo "Updating package lists..."
sudo apt-get update -y

# Install Docker
echo "Installing Docker..."
sudo apt-get install docker.io -y

# Add the current user to the Docker group
echo "Adding user to Docker group..."
sudo usermod -aG docker $USER

# Apply new group membership (effective for future sessions)
# Note: 'newgrp' creates a new shell; in scripts, it may not have the intended effect
# Therefore, Docker commands will be prefixed with 'sudo'
# Alternatively, you can log out and back in to apply group changes

# Adjust Docker socket permissions (if necessary)
echo "Adjusting Docker socket permissions..."
sudo chmod 666 /var/run/docker.sock

echo "Docker installation complete."

# Install Docker Compose
echo "Installing Docker Compose..."
sudo apt-get install docker-compose -y

# Verify Docker Compose installation
docker-compose --version

echo "Docker Compose installation complete."

echo "Setting up Splunk..."

# Pull the latest Splunk image
echo "Pulling Splunk Docker image..."
sudo docker pull splunk/splunk:latest

# Run Splunk container
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

# Function to execute Splunk CLI commands inside the Docker container
splunk_exec() {
    local cmd="$1"
    sudo docker exec splunk /opt/splunk/bin/splunk ${cmd} -auth admin:"${SPLUNK_PASSWORD}"
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
