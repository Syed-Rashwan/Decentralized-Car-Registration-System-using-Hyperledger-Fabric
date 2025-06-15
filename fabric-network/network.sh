#!/bin/bash

# Exit on first error
set -e

# Set up environment
export FABRIC_CFG_PATH=$PWD

CHANNEL_NAME="mychannel"
CHAINCODE_NAME="carcontract"

function generateCrypto() {
  echo "🔧 Generating crypto material..."
  if [ -d "crypto-config" ]; then
    rm -rf crypto-config
  fi
  cryptogen generate --config=./crypto-config.yaml --output ./crypto-config
}

function generateChannelArtifacts() {
  echo "📋 Generating channel artifacts..."
  mkdir -p channel-artifacts

  configtxgen -profile OneOrgOrdererGenesis -channelID system-channel -outputBlock ./channel-artifacts/genesis.block
  configtxgen -profile OneOrgChannel -channelID $CHANNEL_NAME -outputCreateChannelTx ./channel-artifacts/channel.tx
}

function startNetwork() {
  echo "🚀 Starting the network..."
  docker-compose up -d
}

function createChannel() {
  echo " Creating channel..."
  docker exec -e FABRIC_CFG_PATH=/etc/hyperledger/fabric cli peer channel create -o orderer:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls true --cafile /etc/hyperledger/orderer/tls/ca.crt
}

function joinChannel() {
  echo " Joining channel..."
  docker exec -e FABRIC_CFG_PATH=/etc/hyperledger/fabric cli peer channel join -b $CHANNEL_NAME.block
}

function installChaincode() {
  echo " Installing chaincode..."
  docker exec -e FABRIC_CFG_PATH=/etc/hyperledger/fabric cli peer chaincode install -n $CHAINCODE_NAME -v 1.0 -p /opt/gopath/src/github.com/chaincode/carcontract -l node
}

function instantiateChaincode() {
  echo " Instantiating chaincode..."
  docker exec -e FABRIC_CFG_PATH=/etc/hyperledger/fabric cli peer chaincode instantiate -o orderer:7050 -C $CHANNEL_NAME -n $CHAINCODE_NAME -v 1.0 -c '{"Args":["init"]}' -P "AND ('Org1MSP.member')" --tls true --cafile /etc/hyperledger/orderer/tls/ca.crt
}

function networkDown() {
  echo " Cleaning up..."
  docker-compose down --volumes --remove-orphans
  rm -rf crypto-config channel-artifacts *.block
}

# Start network
if [ "$1" == "down" ]; then
  networkDown
else
  networkDown # Clean up before starting
  generateCrypto
  generateChannelArtifacts
  startNetwork
  sleep 10
  createChannel
  joinChannel
  installChaincode
  instantiateChaincode
fi
