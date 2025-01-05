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

## Development

This project uses Hardhat for development and testing.

### Install Dependencies

```shell
npm install
```

### Run Tests

```shell
npx hardhat test
```

### Local Deployment

```shell
npx hardhat node
npx hardhat run scripts/deploy.js --network localhost
```

### Deploy to Testnet

```shell
npx hardhat run scripts/deploy.js --network sepolia
```

## Contract Verification

You can verify the contract on Sepolia Etherscan using:

```shell
npx hardhat verify --network sepolia 0x760410d585110e149233919357E7C866bb51A841
```

## License

MIT
