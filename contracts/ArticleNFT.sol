// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

error NameEmpty();
error ContentHashEmpty();
error ArweaveIdEmpty();
error MaxSupplyInvalid();
error RoyaltyFeeTooHigh();
error InsufficientPayment();
error ExceedsMaxSupply();
error AlreadyMinted();
error TokenNotExist();
error NoBalanceToWithdraw();
error NotTokenOwner();
error NotAuthorized();

contract ArticleNFT is ERC721, Ownable, IERC2981 {
    uint96 private immutable PLATFORM_FEE = 1000; // 10%
    
    struct Article {
        address author;         // 作者地址
        string name;            // 文章名称
        string contentHash;     // 文章内容哈希
        string arweaveId;       // Arweave 交易ID
        string version;         // 版本号
        uint256 timestamp;      // 铸造时间戳
        uint256 price;          // 铸造价格
        uint256 maxSupply;      // 最大铸造数量
        uint96 royaltyFee;      // 版税比例
        bool onePerAddress;     // 是否限制每个地址只能铸造一次
    }

    mapping(uint256 => Article) public articles;
    mapping(uint256 => uint256) public mintedCount;
    mapping(uint256 => mapping(address => bool)) public hasMinted;

    event ArticleMinted(
        uint256 indexed tokenId,
        address indexed author,
        address indexed minter,
        string name,
        uint256 price,
        string contentHash,
        string arweaveId,
        string version
    );

    constructor() ERC721("Article NFT", "ANFT") {
    }

    function mintArticle(
        address author,
        string memory name,
        string memory contentHash,
        string memory arweaveId,
        string memory version,
        uint256 price,
        uint256 maxSupply,
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
            arweaveId
        )));
        
        if (articles[articleId].author == address(0)) {
            articles[articleId] = Article({
                author: author,
                name: name,
                contentHash: contentHash,
                arweaveId: arweaveId,
                version: version,
                timestamp: block.timestamp,
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