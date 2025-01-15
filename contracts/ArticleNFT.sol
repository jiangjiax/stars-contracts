// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

// 自定义错误定义，比 require 更节省 gas
error NameEmpty();              // 文章名称为空
error ContentHashEmpty();       // 内容哈希为空
error ArweaveIdEmpty();        // Arweave ID为空
error MaxSupplyInvalid();      // 最大供应量无效（为0）
error RoyaltyFeeTooHigh();     // 版税比例超过100%（10000）
error InsufficientPayment();   // 支付金额不足
error ExceedsMaxSupply();      // 超过最大铸造数量
error AlreadyMinted();         // 该地址已经铸造过（onePerAddress=true时）
error TokenNotExist();         // NFT不存在
error NoBalanceToWithdraw();   // 没有余额可提取
error NotTokenOwner();         // 不是NFT的所有者
error NotAuthorized();         // 未经授权的操作

contract ArticleNFT is ERC721, Ownable, IERC2981 {
    // 平台费率：10%，使用 constant 而不是 immutable 可以节省 gas
    uint96 private constant PLATFORM_FEE = 1000; // 基数为10000
    
    // 文章结构体 - 优化存储布局，将相同大小的字段放在一起
    struct Article {
        address author;         // 作者地址
        string name;            // 文章名称
        string contentHash;     // 文章内容的IPFS哈希
        string arweaveId;       // Arweave上的永久存储ID
        string version;         // 文章版本号
        uint32 timestamp;       // 铸造时间戳 (uint32足够用到2106年)
        uint96 price;          // 铸造价格 (uint96对于价格来说足够大)
        uint32 maxSupply;      // 最大铸造数量 (uint32对于NFT数量来说足够)
        uint96 royaltyFee;     // 版税比例，基数为10000
        bool onePerAddress;     // 是否限制每个地址只能铸造一次
    }

    // 存储映射
    mapping(uint256 => Article) public articles;           // tokenId => 文章详情
    mapping(uint256 => uint32) public mintedCount;        // tokenId => 已铸造数量
    mapping(uint256 => mapping(address => bool)) public hasMinted;  // tokenId => 地址 => 是否已铸造

    // 铸造事件
    event ArticleMinted(
        uint256 indexed tokenId,    // 文章NFT的ID
        address indexed author,      // 作者地址
        address indexed minter,      // 铸造者地址
        string name,                // 文章名称
        uint256 price,              // 铸造价格
        string contentHash,         // 内容哈希
        string arweaveId,          // Arweave ID
        string version             // 版本号
    );

    /**
     * @dev 构造函数 - 初始化NFT集合名称和符号
     */
    constructor() ERC721("Article NFT", "ANFT") {
    }

    /**
     * @dev 铸造文章NFT
     * @param author 作者地址
     * @param name 文章名称
     * @param contentHash IPFS内容哈希
     * @param arweaveId Arweave交易ID
     * @param version 版本号
     * @param price 铸造价格
     * @param maxSupply 最大供应量
     * @param royaltyFee 版税比例（基数10000）
     * @param onePerAddress 是否限制每地址只能铸造一次
     * @return 返回铸造的NFT ID
     */
    function mintArticle(
        address author,
        string calldata name,        // 使用calldata节省gas
        string calldata contentHash,
        string calldata arweaveId,
        string calldata version,
        uint96 price,
        uint32 maxSupply,
        uint96 royaltyFee,
        bool onePerAddress
    ) public payable returns (uint256) {
        if(bytes(name).length == 0) revert NameEmpty();
        if(bytes(contentHash).length == 0) revert ContentHashEmpty();
        if(bytes(arweaveId).length == 0) revert ArweaveIdEmpty();
        if(maxSupply == 0) revert MaxSupplyInvalid();
        if(royaltyFee > 10000) revert RoyaltyFeeTooHigh();
        if(msg.value < price) revert InsufficientPayment();
        
        uint256 articleId = uint256(keccak256(abi.encodePacked(
            contentHash,
            author
        )));
        
        if (articles[articleId].author == address(0)) {
            articles[articleId] = Article({
                author: author,
                name: name,
                contentHash: contentHash,
                arweaveId: arweaveId,
                version: version,
                timestamp: uint32(block.timestamp),
                price: price,
                maxSupply: maxSupply,
                royaltyFee: royaltyFee,
                onePerAddress: onePerAddress
            });
        } else {
            Article memory article = articles[articleId];
            if(mintedCount[articleId] >= article.maxSupply) revert ExceedsMaxSupply();
            if(article.onePerAddress && hasMinted[articleId][msg.sender]) revert AlreadyMinted();
        }

        if (price > 0) {
            uint256 platformFee = (msg.value * PLATFORM_FEE) / 10000;
            unchecked {
                payable(author).transfer(msg.value - platformFee);
            }
            payable(owner()).transfer(platformFee);
        }

        _safeMint(msg.sender, articleId);
        
        unchecked {
            mintedCount[articleId]++;
        }
        hasMinted[articleId][msg.sender] = true;

        emit ArticleMinted(articleId, author, msg.sender, name, msg.value, contentHash, arweaveId, version);
        return articleId;
    }

    /**
     * @dev 实现 ERC2981 版税接口
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        if(_ownerOf(tokenId) == address(0)) revert TokenNotExist();
        Article memory article = articles[tokenId];
        
        if (article.royaltyFee == 0) {
            return (address(0), 0);
        }
        
        return (
            article.author,
            (salePrice * article.royaltyFee) / 10000
        );
    }

    /**
     * @dev 获取文章详情
     */
    function getArticle(uint256 articleId)
        public
        view
        returns (
            address author,
            string memory name,
            string memory contentHash,
            string memory arweaveId,
            string memory version,
            uint256 timestamp,
            uint256 price,
            uint256 maxSupply,
            uint256 currentSupply,
            uint96 royaltyFee,
            bool onePerAddress
        )
    {
        Article memory article = articles[articleId];
        return (
            article.author,
            article.name,
            article.contentHash,
            article.arweaveId,
            article.version,
            article.timestamp,
            article.price,
            article.maxSupply,
            mintedCount[articleId],
            article.royaltyFee,
            article.onePerAddress
        );
    }

    /**
     * @dev 提取合约中的ETH（仅合约拥有者）
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        if(balance == 0) revert NoBalanceToWithdraw();
        payable(owner()).transfer(balance);
    }

    /**
     * @dev 销毁 NFT
     * @param tokenId 要销毁的 NFT ID
     */
    function burnArticle(uint256 tokenId) public {
        if(_ownerOf(tokenId) != msg.sender) revert NotTokenOwner();
        _burn(tokenId);
    }
} 