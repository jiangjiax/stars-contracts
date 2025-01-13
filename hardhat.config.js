require("@nomicfoundation/hardhat-toolbox");
require("@typechain/hardhat");
require("@nomicfoundation/hardhat-ethers");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY_TEST]
    },
    telosTestnet: {
      url: "https://testnet.telos.net/evm",
      accounts: [process.env.PRIVATE_KEY_TEST],
      chainId: 41
    }
  }
};
