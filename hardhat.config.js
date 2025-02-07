require("@nomicfoundation/hardhat-toolbox");
require("@typechain/hardhat");
require("@nomicfoundation/hardhat-ethers");
require("dotenv").config();
require("hardhat-gas-reporter");

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
  gasReporter: {
    enabled: true,
    token: "TLOS",
    offline: true,
    showTimeSpent: true,
    showMethodSig: true,
    maxMethodDiff: 10,
    outputFile: "gas-report.txt",
    noColors: true,
    src: "./contracts",
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
    },
    telosMainnet: {
      url: "https://mainnet.telos.net/evm",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 40
    },
    eduTestnet: {
      url: "https://open-campus-codex-sepolia.drpc.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 656476,
    }
  }
};
