const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const fs = require('fs');

const channelName = 'mychannel';
const chaincodeName = 'carcontract';
const mspOrg1 = 'Org1MSP';

async function getFabricConnection(userId = 'appUser', isLocalhost = true) {
  try {
    const ccpPath = path.resolve(__dirname, '..', 'fabric-network', 'connection-org1.json');
    const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

    const walletPath = path.join(process.cwd(), 'wallet');
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);

    const identity = await wallet.get(userId);
    if (!identity) {
      console.log(`An identity for the user "${userId}" does not exist in the wallet`);
      console.log('Run the registerUser.js application before retrying');
      return;
    }

    const gateway = new Gateway();
    await gateway.connect(ccp, {
      wallet, identity: userId, discovery: { enabled: true, asLocalhost: isLocalhost }, tlsOptions: { trustedRoots: [], verify: false }
    });

    const network = await gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeName);

    return { gateway, contract };

  } catch (error) {
    console.error(`Failed to connect to Fabric network: ${error}`);
    throw error;
  }
}

exports.registerCar = async (carId, model, owner, userId = 'appUser') => {
  try {
    const { contract } = await getFabricConnection(userId);
    console.log(`\n--> Submit Transaction: registerCar, function creates the car in the ledger`);
    const result = await contract.submitTransaction('registerCar', carId, model, owner);
    console.log('*** Result: committed');
    return result;
  } catch (error) {
    console.error(`Failed to submit transaction: ${error}`);
    throw error;
  }
};

exports.queryAllCars = async (userId = 'appUser') => {
  try {
    const { contract } = await getFabricConnection(userId);
    console.log('\n--> Evaluate Transaction: queryAllCars, function returns all the cars currently in the ledger');
    const result = await contract.evaluateTransaction('queryAllCars');
    console.log(`*** Result: ${result.toString()}`);
    return result.toString();
  } catch (error) {
    console.error(`Failed to evaluate transaction: ${error}`);
    throw error;
  }
};

exports.getCar = async (carId, userId = 'appUser') => {
  try {
    const { contract } = await getFabricConnection(userId);
    console.log(`\n--> Evaluate Transaction: getCar, function returns the car with the carId in the ledger`);
    const result = await contract.evaluateTransaction('getCar', carId);
    console.log(`*** Result: ${result.toString()}`);
    return result.toString();
  } catch (error) {
    console.error(`Failed to evaluate transaction: ${error}`);
    throw error;
  }
};
