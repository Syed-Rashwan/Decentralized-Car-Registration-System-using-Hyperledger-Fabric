#!/bin/bash

# Exit on first error
set -e

export FABRIC_CFG_PATH=$PWD

# Generate crypto material using cryptogen tool
cryptogen generate --config=./crypto-config.yaml

# Generate genesis block and channel configuration transaction
configtxgen -profile OneOrgOrdererGenesis -outputBlock ./channel-artifacts/genesis.block -channelID mychannel

configtxgen -profile OneOrgChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel

echo "Crypto material and channel artifacts generated successfully."
