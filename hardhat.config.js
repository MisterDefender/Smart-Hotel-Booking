require("@nomicfoundation/hardhat-toolbox");
require('hardhat-deploy');
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    },
  
  },
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: { default: 0 },
  },
  networks: {
    hardhat:{
      allowUnlimitedContractSize: false
    },
    Columbus: {
      accounts: [process.env.OWNER_PVT_KEY],
      url: `https://columbus.camino.network/ext/bc/C/rpc`,
      gasPrice: "auto",
      saveDeployments: true,
      live: true,
      gasMultiplier: 2,
    },
    Camino: {
      accounts: [process.env.OWNER_PVT_KEY],
      url: `https://api.camino.network/ext/bc/C/rpc`,
      gasPrice: "auto",
      saveDeployments: true,
      live: true,
      gasMultiplier: 2,
    },
  },
  etherscan: {
    apiKey: {
      arbitrumSepolia: process.env.ARBITRUM_API_KEY,
      arbitrumOne: process.env.ARBITRUM_API_KEY,
    },
  },

sourcify: {
  enabled: true
},


};
