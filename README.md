# Stars NFT Contract

This is the NFT smart contract for the Stars project, which enables authors to tokenize their articles as NFTs.

## Contract Features

- Mint article NFTs with customizable parameters
- Set royalty fees for secondary sales
- Control maximum supply per article
- Option to limit one NFT per address
- Platform fee mechanism (10%)

## Deployed Contracts

| Network | Contract Address |
|---------|-----------------|
| Ethereum Sepolia | [0x760410d585110e149233919357E7C866bb51A841](https://sepolia.etherscan.io/address/0x760410d585110e149233919357E7C866bb51A841) |
| Telos Testnet | [0x4AB01dd5Fe790F01CF8814610e2388550064B6ed](https://testnet.teloscan.io/address/0x4AB01dd5Fe790F01CF8814610e2388550064B6ed) |

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

## Contract Verification

### Sepolia
```shell
npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
```

### Telos Testnet
Contract verification can be done on the Telos testnet explorer:
https://testnet.teloscan.io/

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