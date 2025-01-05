const hre = require("hardhat");

async function main() {
  const ArticleNFT = await hre.ethers.getContractFactory("ArticleNFT");
  const articleNFT = await ArticleNFT.deploy();

  await articleNFT.waitForDeployment();

  const address = await articleNFT.getAddress();
  console.log("ArticleNFT deployed to:", address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
}); 