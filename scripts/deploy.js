const hre = require("hardhat");

async function main() {
  console.log("Deploying ArticleNFT contract...");
  
  const ArticleNFT = await hre.ethers.getContractFactory("ArticleNFT");
  const articleNFT = await ArticleNFT.deploy({
    gasLimit: 3000000
  });

  await articleNFT.waitForDeployment();

  const address = await articleNFT.getAddress();
  console.log("ArticleNFT deployed to:", address);
  
  const network = await hre.ethers.provider.getNetwork();
  console.log("Network:", {
    name: network.name,
    chainId: network.chainId
  });

  console.log("Deployment completed!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
}); 