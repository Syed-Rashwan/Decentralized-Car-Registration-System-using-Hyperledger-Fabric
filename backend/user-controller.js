const path = require('path');
const { exec } = require('child_process');
const { Wallets } = require('fabric-network');

const walletPath = path.join(process.cwd(), 'wallet');

exports.registerUser = async (req, res) => {
  const { username } = req.body;
  if (!username) {
    return res.status(400).json({ error: 'Username is required' });
  }

  // Run the registerUser.js script as a child process
  exec(`node ${path.join(__dirname, 'registerUser.js')} ${username}`, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error registering user: ${error.message}`);
      return res.status(500).json({ error: error.message });
    }
    if (stderr) {
      console.error(`stderr: ${stderr}`);
    }
    console.log(`stdout: ${stdout}`);
    if (stdout.includes('Successfully registered and enrolled user')) {
      return res.json({ message: `User ${username} registered successfully` });
    } else {
      return res.status(500).json({ error: 'Failed to register user' });
    }
  });
};

exports.loginUser = async (req, res) => {
  const { username } = req.body;
  if (!username) {
    return res.status(400).json({ error: 'Username is required' });
  }

  try {
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    const identity = await wallet.get(username);
    if (!identity) {
      return res.status(401).json({ error: 'User identity not found. Please register first.' });
    }
    // For simplicity, no password is checked as Fabric uses certificate-based auth
    return res.json({ message: `User ${username} logged in successfully` });
  } catch (error) {
    console.error(`Error during login: ${error}`);
    return res.status(500).json({ error: error.message });
  }
};
