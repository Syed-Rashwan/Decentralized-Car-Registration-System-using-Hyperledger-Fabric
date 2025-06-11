#!/bin/bash

# Exit on first error
set -e

# Set environment variables
export PATH=/home/rashwan_unix/fabric-samples/bin:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=true

# Function to check if Docker containers are running
check_containers() {
    local containers=("orderer.example.com" "peer0.org1.example.com" "ca_peerOrg1" "cli")
    for container in "${containers[@]}"; do
        if [ "$(docker ps -q -f name=^/${container}$)" ]; then
            echo "$container is running"
        else
            echo "$container failed to start"
            exit 1
        fi
    done
}

# Clean up existing artifacts
echo "Cleaning up existing artifacts..."
rm -rf channel-artifacts/*
rm -rf crypto-config/*

# Bring down any existing network
docker-compose -f docker-compose.yaml down
docker system prune -f
docker volume prune -f

# Create required directories
mkdir -p channel-artifacts
mkdir -p crypto-config

# Generate crypto material
echo "Generating crypto material..."
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
    echo "Failed to generate crypto material..."
    exit 1
fi

# Generate genesis block
echo "Generating genesis block..."
configtxgen -profile OneOrgOrdererGenesis -channelID system-channel -outputBlock ./channel-artifacts/genesis.block
if [ "$?" -ne 0 ]; then
    echo "Failed to generate genesis block..."
    exit 1
fi

# Generate channel configuration transaction
echo "Generating channel configuration transaction..."
configtxgen -profile OneOrgChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel
if [ "$?" -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
fi

# Generate anchor peer update for Org1MSP
echo "Generating anchor peer update for Org1MSP..."
configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
    echo "Failed to generate anchor peer update..."
    exit 1
fi

# Start the network
echo "Starting Fabric network..."
docker-compose -f docker-compose.yaml up -d
if [ "$?" -ne 0 ]; then
    echo "Failed to start network..."
    exit 1
fi

# Wait for containers to start
echo "Waiting for containers to start..."
sleep 15

# Check if all containers are running
echo "Checking container status..."
check_containers

# Create the channel
echo "Creating channel and deploying chaincode..."
docker exec cli scripts/script.sh mychannel 3 node 10 false

echo "Fabric network started successfully!"
echo "You can now start the backend API and frontend."
