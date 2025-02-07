# Stars NFT Contract

This is the NFT smart contract for the Stars project, which enables authors to tokenize their articles as NFTs.

## Contract Features

- Mint article NFTs with customizable parameters
- Set royalty fees for secondary sales
- Control maximum supply per article
- Option to limit one NFT per address
- Platform fee mechanism (10%)

## Deployed Contracts

| Network | Contract Address | Chain ID |
|---------|-----------------|---------|
| Ethereum Sepolia | [0x5c83f2287833F567b1D80D7B981084eb5CaeF445](https://sepolia.etherscan.io/address/0x5c83f2287833F567b1D80D7B981084eb5CaeF445) | 11155111 |
| Telos Testnet | [0x903e48Ca585dBF4dFeb74f2864501feB6f0dF369](https://testnet.teloscan.io/address/0x903e48Ca585dBF4dFeb74f2864501feB6f0dF369) | 41 |
| Edu Testnet | [0xcA3Dbe8eF976e606B8c96052aaC22763aDeAEE0A](https://edu-chain-testnet.blockscout.com/address/0xcA3Dbe8eF976e606B8c96052aaC22763aDeAEE0A) | 656476 |

## Development

This project uses Hardhat for development and testing.

### Install Dependencies

```shell
npm install
```

### Run Tests

```shell
# Run all tests
npx hardhat test

# Run specific test file
npx hardhat test test/ArticleNFT.test.js
```

### Local Deployment

```shell
# Start local node
npx hardhat node

# Deploy to local network
npx hardhat run scripts/deploy.js --network localhost
```

### Deploy to Testnets

#### Sepolia
```shell
npx hardhat run scripts/deploy.js --network sepolia
```

#### Telos Testnet
1. Get test TLOS from faucet:
   - Visit https://app.telos.net/testnet/faucet
   - Enter your wallet address
   - Request test tokens

2. Deploy contract:
```shell
npx hardhat run scripts/deploy.js --network telosTestnet
```

### Deploy to Mainnet

#### Telos Mainnet
1. Ensure you have TLOS in your wallet for deployment

2. Deploy contract:
```shell
npx hardhat run scripts/deploy.js --network telosMainnet
```

## Contract Verification

### Sepolia
```shell
npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
```

### Telos Testnet
Contract verification can be done on the Telos testnet explorer:
https://testnet.teloscan.io/

### Telos Mainnet
1. Get the flattened contract:
```shell
npx hardhat flatten contracts/ArticleNFT.sol > ArticleNFTFlat.sol
```

2. Go to Telos Explorer:
   - Visit https://www.teloscan.io/
   - Find your contract
   - Click "Verify & Publish"
   - Select Solidity Single File
   - Compiler Version: v0.8.28
   - Optimization: Yes (200 runs)
   - License: MIT
   - Paste the flattened contract code
   - Submit for verification

## Testing Steps

1. Local Testing:
```shell
# Start local node in one terminal
npx hardhat node

# Deploy in another terminal
npx hardhat run scripts/deploy.js --network localhost

# Run tests
npx hardhat test
```

2. Testnet Testing:
```shell
# Deploy to testnet
npx hardhat run scripts/deploy.js --network telosTestnet

# Interact using console
npx hardhat console --network telosTestnet

# In console:
> const ArticleNFT = await ethers.getContractFactory("ArticleNFT")
> const articleNFT = await ArticleNFT.attach("DEPLOYED_CONTRACT_ADDRESS")
> const [owner] = await ethers.getSigners()
> await articleNFT.owner()  // Should return your address
```

## License

MIT