#!/bin/bash

# Exit on first error
set -e

# Environment variables
export FABRIC_CFG_PATH=$PWD
CHANNEL_NAME="mychannel"
CHAINCODE_NAME="carcontract"
CHAINCODE_LABEL="${CHAINCODE_NAME}_1"
CHAINCODE_PATH="/opt/gopath/src/github.com/chaincode/${CHAINCODE_NAME}"
CHAINCODE_LANG="node"
CHAINCODE_VERSION="1.0"
SEQUENCE=1

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

  echo "⏳ Waiting for containers to start..."
  sleep 5
  
  echo "⏳ Checking if orderer container is running..."
  until [ "$(docker ps -q -f name=orderer)" ]; do
    echo "Waiting for orderer container to start..."
    sleep 2
  done
  
  echo "⏳ Checking if peer container is running..."
  until [ "$(docker ps -q -f name=peer0.example.com)" ]; do
    echo "Waiting for peer container to start..."
    sleep 2
  done

  echo "⏳ Waiting for orderer to be ready..."
  sleep 5
  until nc -z localhost 7050 2>/dev/null; do
    echo "Waiting for orderer to listen on port 7050..."
    sleep 2
  done

  echo "⏳ Waiting for peer to be ready..."
  sleep 5
  until nc -z localhost 7051 2>/dev/null; do
    echo "Waiting for peer to listen on port 7051..."
    sleep 2
  done

  echo "✅ Network is ready"
}

function createChannel() {
  echo "📡 Creating channel..."
  
  # Copy channel.tx to CLI container
  docker cp ./channel-artifacts/channel.tx cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel.tx
  
  echo "Creating channel with name: $CHANNEL_NAME"
  docker exec cli peer channel create \
    -o orderer:7050 \
    --connTimeout 10s \
    -c $CHANNEL_NAME \
    -f channel.tx \
    --outputBlock ${CHANNEL_NAME}.block \
    --tls true \
    --cafile /etc/hyperledger/orderer/tls/ca.crt

  # Verify channel block was created
  if docker exec cli test -f ${CHANNEL_NAME}.block; then
    echo "✅ Channel block created successfully"
  else
    echo "❌ Failed to create channel block"
    exit 1
  fi
}

function joinChannel() {
  echo "🤝 Joining channel..."
  docker exec cli peer channel join -b ${CHANNEL_NAME}.block
}

function installChaincode() {
  echo "📦 Packaging chaincode..."
  docker exec cli peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz \
    --path $CHAINCODE_PATH \
    --lang $CHAINCODE_LANG \
    --label $CHAINCODE_LABEL

  echo "📥 Installing chaincode..."
  docker exec cli peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

  echo "🔍 Querying installed chaincode to get Package ID..."
  PACKAGE_ID=$(docker exec cli peer lifecycle chaincode queryinstalled | grep "$CHAINCODE_LABEL" | awk -F[,:] '{print $3}' | xargs)
  echo "📦 Package ID: $PACKAGE_ID"

  echo $PACKAGE_ID > package.id
}

function approveAndCommitChaincode() {
  PACKAGE_ID=$(cat package.id)

  echo "✅ Approving chaincode for Org1..."
  docker exec cli peer lifecycle chaincode approveformyorg \
    -o orderer:7050 \
    --connTimeout 10s \
    --channelID $CHANNEL_NAME \
    --name $CHAINCODE_NAME \
    --version $CHAINCODE_VERSION \
    --package-id $PACKAGE_ID \
    --sequence $SEQUENCE \
    --waitForEvent \
    --init-required \
    --tls \
    --cafile /etc/hyperledger/orderer/tls/ca.crt \
    --peerAddresses peer0.example.com:7051 \
    --tlsRootCertFiles /etc/hyperledger/fabric/tls/ca.crt

  echo "🧾 Committing chaincode definition..."
  docker exec cli peer lifecycle chaincode commit \
    -o orderer:7050 \
    --connTimeout 10s \
    --channelID $CHANNEL_NAME \
    --name $CHAINCODE_NAME \
    --version $CHAINCODE_VERSION \
    --sequence $SEQUENCE \
    --waitForEvent \
    --init-required \
    --tls \
    --cafile /etc/hyperledger/orderer/tls/ca.crt \
    --peerAddresses peer0.example.com:7051 \
    --tlsRootCertFiles /etc/hyperledger/fabric/tls/ca.crt
}

function initChaincode() {
  echo "🚀 Invoking Init on chaincode..."
  docker exec cli peer chaincode invoke \
    -o orderer:7050 \
    --connTimeout 10s \
    --tls \
    --cafile /etc/hyperledger/orderer/tls/ca.crt \
    --peerAddresses peer0.example.com:7051 \
    --tlsRootCertFiles /etc/hyperledger/fabric/tls/ca.crt \
    -C $CHANNEL_NAME \
    -n $CHAINCODE_NAME \
    --isInit \
    -c '{"Args":["Init"]}'
}

function networkDown() {
  echo "🧹 Cleaning up..."
  docker-compose down --volumes --remove-orphans
  rm -rf crypto-config channel-artifacts *.block *.tar.gz package.id
}

# Main flow
if [ "$1" == "down" ]; then
  networkDown
else
  networkDown # Clean up before starting
  generateCrypto
  generateChannelArtifacts
  startNetwork
  sleep 20
  createChannel
  joinChannel
  installChaincode
  approveAndCommitChaincode
  initChaincode
fi