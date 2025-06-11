# PowerShell script to download Hyperledger Fabric binaries for Windows

$fabricVersion = "2.2.0"
$fabricSamplesVersion = "2.2.0"

# Correct URLs for Fabric binaries and samples zip files for Windows
$binZipUrl = "https://github.com/hyperledger/fabric/releases/download/v$fabricVersion/hyperledger-fabric-windows-amd64-$fabricVersion.zip"
$samplesZipUrl = "https://github.com/hyperledger/fabric-samples/releases/download/v$fabricSamplesVersion/hyperledger-fabric-samples-windows-amd64-$fabricSamplesVersion.zip"

$binZip = "hyperledger-fabric-windows-amd64-$fabricVersion.zip"
$samplesZip = "hyperledger-fabric-samples-windows-amd64-$fabricSamplesVersion.zip"

Write-Host "Downloading Fabric binaries..."
Invoke-WebRequest -Uri $binZipUrl -OutFile $binZip

Write-Host "Downloading Fabric samples..."
Invoke-WebRequest -Uri $samplesZipUrl -OutFile $samplesZip

Write-Host "Extracting Fabric binaries..."
Expand-Archive -Path $binZip -DestinationPath "./fabric-binaries" -Force

Write-Host "Extracting Fabric samples..."
Expand-Archive -Path $samplesZip -DestinationPath "./fabric-samples" -Force

Write-Host "Cleaning up zip files..."
if (Test-Path $binZip) {
    Remove-Item -Path $binZip
}
if (Test-Path $samplesZip) {
    Remove-Item -Path $samplesZip
}

Write-Host "Fabric binaries and samples downloaded and extracted to ./fabric-binaries and ./fabric-samples"
Write-Host "Please add ./fabric-binaries to your system PATH to use Fabric tools like cryptogen."
