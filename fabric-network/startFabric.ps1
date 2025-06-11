# PowerShell script to start Fabric network and deploy chaincode on Windows

# Stop and remove any existing containers
docker-compose -f docker-compose.yaml down

# Start Fabric network containers
docker-compose -f docker-compose.yaml up -d ca.org1.example.com orderer.example.com peer0.org1.example.com

# Wait for network to start
Start-Sleep -Seconds 10

# Set environment variables for peer CLI commands
$env:CORE_PEER_LOCALMSPID = "Org1MSP"
$env:CORE_PEER_MSPCONFIGPATH = (Resolve-Path .\crypto-config\peerOrganizations\org1.example.com\users\Admin@org1.example.com\msp)
$env:CORE_PEER_ADDRESS = "localhost:7051"

# Create channel
peer channel create -o localhost:7050 -c mychannel -f .\channel-artifacts\channel.tx

# Join peer to channel
peer channel join -b mychannel.block

# Install chaincode
peer chaincode install -n carcontract -v 1.0 -p .\chaincode\carcontract

# Instantiate chaincode
peer chaincode instantiate -o localhost:7050 -C mychannel -n carcontract -v 1.0 -c '{"Args":[]}' -P "OR ('Org1MSP.member')"

Write-Host "Fabric network started and chaincode instantiated."
