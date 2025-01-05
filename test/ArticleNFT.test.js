const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ArticleNFT", function () {
  let articleNFT;
  let owner;
  let author;
  let reader1;
  let reader2;

  const articleData = {
    name: "Test Article",
    contentHash: "QmTest123",
    arweaveId: "ArweaveTest123",
    version: "1.0.0",
    price: ethers.parseEther("0.1"),
    maxSupply: 10,
    royaltyFee: 250, // 2.5%
    onePerAddress: true
  };

  beforeEach(async function () {
    [owner, author, reader1, reader2] = await ethers.getSigners();
    
    const ArticleNFT = await ethers.getContractFactory("ArticleNFT");
    articleNFT = await ArticleNFT.deploy();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await articleNFT.owner()).to.equal(owner.address);
    });

    it("Should have correct name and symbol", async function () {
      expect(await articleNFT.name()).to.equal("Article NFT");
      expect(await articleNFT.symbol()).to.equal("ANFT");
    });
  });

  describe("Minting", function () {
    it("Should mint a new article NFT", async function () {
      await expect(articleNFT.connect(reader1).mintArticle(
        author.address,
        articleData.name,
        articleData.contentHash,
        articleData.arweaveId,
        articleData.version,
        articleData.price,
        articleData.maxSupply,
        articleData.royaltyFee,
        articleData.onePerAddress,
        { value: articleData.price }
      )).to.emit(articleNFT, "ArticleMinted");
    });

    it("Should not mint with insufficient payment", async function () {
      await expect(articleNFT.connect(reader1).mintArticle(
        author.address,
        articleData.name,
        articleData.contentHash,
        articleData.arweaveId,
        articleData.version,
        articleData.price,
        articleData.maxSupply,
        articleData.royaltyFee,
        articleData.onePerAddress,
        { value: 0 }
      )).to.be.revertedWithCustomError(articleNFT, "InsufficientPayment");
    });

    it("Should not exceed max supply", async function () {
      const smallSupply = 1;
      
      await articleNFT.connect(reader1).mintArticle(
        author.address,
        articleData.name,
        articleData.contentHash,
        articleData.arweaveId,
        articleData.version,
        articleData.price,
        smallSupply,
        articleData.royaltyFee,
        articleData.onePerAddress,
        { value: articleData.price }
      );

      await expect(articleNFT.connect(reader2).mintArticle(
        author.address,
        articleData.name,
        articleData.contentHash,
        articleData.arweaveId,
        articleData.version,
        articleData.price,
        smallSupply,
        articleData.royaltyFee,
        articleData.onePerAddress,
        { value: articleData.price }
      )).to.be.revertedWithCustomError(articleNFT, "ExceedsMaxSupply");
    });

    it("Should enforce one per address limit", async function () {
      await articleNFT.connect(reader1).mintArticle(
        author.address,
        articleData.name,
        articleData.contentHash,
        articleData.arweaveId,
        articleData.version,
        articleData.price,
        articleData.maxSupply,
        articleData.royaltyFee,
        true,
        { value: articleData.price }
      );

      await expect(articleNFT.connect(reader1).mintArticle(
        author.address,
        articleData.name,
        articleData.contentHash,
        articleData.arweaveId,
        articleData.version,
        articleData.price,
        articleData.maxSupply,
        articleData.royaltyFee,
        true,
        { value: articleData.price }
      )).to.be.revertedWithCustomError(articleNFT, "AlreadyMinted");
    });
  });

  describe("Royalties", function () {
    it("Should return correct royalty info", async function () {
      await articleNFT.connect(reader1).mintArticle(
        author.address,
        articleData.name,
        articleData.contentHash,
        articleData.arweaveId,
        articleData.version,
        articleData.price,
        articleData.maxSupply,
        articleData.royaltyFee,
        articleData.onePerAddress,
        { value: articleData.price }
      );

      const salePrice = ethers.parseEther("1.0");
      const articleId = ethers.solidityPackedKeccak256(
        ["string", "string"],
        [articleData.contentHash, articleData.arweaveId]
      );

      const [receiver, royaltyAmount] = await articleNFT.royaltyInfo(articleId, salePrice);

      expect(receiver).to.equal(author.address);
      expect(royaltyAmount).to.equal((salePrice * BigInt(articleData.royaltyFee)) / 10000n);
    });
  });

  describe("Article Info", function () {
    it("Should return correct article details", async function () {
      await articleNFT.connect(reader1).mintArticle(
        author.address,
        articleData.name,
        articleData.contentHash,
        articleData.arweaveId,
        articleData.version,
        articleData.price,
        articleData.maxSupply,
        articleData.royaltyFee,
        articleData.onePerAddress,
        { value: articleData.price }
      );

      const articleId = ethers.solidityPackedKeccak256(
        ["string", "string"],
        [articleData.contentHash, articleData.arweaveId]
      );

      const article = await articleNFT.getArticle(articleId);

      expect(article.author).to.equal(author.address);
      expect(article.name).to.equal(articleData.name);
      expect(article.contentHash).to.equal(articleData.contentHash);
      expect(article.arweaveId).to.equal(articleData.arweaveId);
      expect(article.version).to.equal(articleData.version);
      expect(article.price).to.equal(articleData.price);
      expect(article.maxSupply).to.equal(articleData.maxSupply);
      expect(article.royaltyFee).to.equal(articleData.royaltyFee);
      expect(article.onePerAddress).to.equal(articleData.onePerAddress);
    });
  });

  describe("Platform Fee", function () {
    it("Should distribute fees correctly", async function () {
      const initialOwnerBalance = await ethers.provider.getBalance(owner.address);
      const initialAuthorBalance = await ethers.provider.getBalance(author.address);

      await articleNFT.connect(reader1).mintArticle(
        author.address,
        articleData.name,
        articleData.contentHash,
        articleData.arweaveId,
        articleData.version,
        articleData.price,
        articleData.maxSupply,
        articleData.royaltyFee,
        articleData.onePerAddress,
        { value: articleData.price }
      );

      const finalOwnerBalance = await ethers.provider.getBalance(owner.address);
      const finalAuthorBalance = await ethers.provider.getBalance(author.address);

      const platformFee = (articleData.price * 1000n) / 10000n; // 10%
      const authorFee = articleData.price - platformFee;

      expect(finalOwnerBalance - initialOwnerBalance).to.equal(platformFee);
      expect(finalAuthorBalance - initialAuthorBalance).to.equal(authorFee);
    });
  });
}); 