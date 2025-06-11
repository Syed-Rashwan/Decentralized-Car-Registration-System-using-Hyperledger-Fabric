# PowerShell script to generate crypto material, channel artifacts, and set up Fabric environment on Windows

# Set Fabric binaries path (update this path to where you have Fabric binaries installed)
$env:PATH += ";C:\fabric-samples\bin"

# Generate crypto material
cryptogen generate --config=./crypto-config.yaml

# Generate genesis block for orderer
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./channel-artifacts/genesis.block

# Generate channel configuration transaction
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel

# Generate anchor peer update for Org1
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP

Write-Host "Crypto material and channel artifacts generated."

# Instructions:
# 1. Ensure you have Fabric binaries (cryptogen, configtxgen, peer, orderer) installed and added to PATH.
# 2. Run this script to generate required artifacts.
# 3. Then run startFabric.ps1 to start the network.
