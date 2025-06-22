#!/bin/bash

# Script to query committed chaincode definition on the channel

CHANNEL_NAME="mychannel"
CHAINCODE_NAME="carcontract"

echo "Querying committed chaincode definition for $CHAINCODE_NAME on channel $CHANNEL_NAME..."

docker exec cli peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name $CHAINCODE_NAME
