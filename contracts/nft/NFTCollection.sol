// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/**
 * Please note the following:
 *
 * 1. This contract assumes that you are using OpenZeppelin ERC721 library for handling NFTs. You should install this library using npm or yarn and import it as shown in the code.
 * 2. Users need to approve the contract to spend their NFTs on their behalf before listing them for sale. This contract does not handle the approval process but assumes that NFTs 
 *    have already been approved.
 * 3. The contract handles basic listing and unlisting of NFTs and allows users to purchase NFTs listed for sale. More advanced features like royalties, auctions, 
 *    or a marketplace interface would require additional development.
 * 4. Ensure proper testing, security audits, and legal considerations before deploying any smart contract to a live blockchain network.
 * 5. Be aware that the Ethereum blockchain and Solidity language are continually evolving, and it's essential to use the latest best practices when creating smart contracts.
 */

import "../interfaces/IERC721.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTCollection {
    // Address of the NFT contract
    IERC721 public nftContract;

    // NFT Struct
    struct NFT {
        uint256 tokenId;
        address owner;
        uint256 price;
        bool forSale;
    }

    // Mapping from NFT ID to NFT details
    mapping(uint256 => NFT) public nfts;

    // Event for when an NFT is listed for sale
    event NFTListed(uint256 tokenId, uint256 price);
    
    // Event for when an NFT is unlisted (taken off the market)
    event NFTUnlisted(uint256 tokenId);

    constructor(address _nftContractAddress) {
        nftContract = IERC721(_nftContractAddress);
    }

    // List an NFT for sale
    function listNFTForSale(uint256 tokenId, uint256 price) public {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You don't own this NFT.");
        require(price > 0, "Price must be greater than 0");

        nfts[tokenId] = NFT(tokenId, msg.sender, price, true);
        emit NFTListed(tokenId, price);
    }

    // Unlist an NFT from sale
    function unlistNFT(uint256 tokenId) public {
        require(nfts[tokenId].owner == msg.sender, "You don't own this NFT.");
        delete nfts[tokenId];
        emit NFTUnlisted(tokenId);
    }

    // Purchase an NFT
    function purchaseNFT(uint256 tokenId) public payable {
        NFT storage nft = nfts[tokenId];
        require(nft.forSale, "NFT is not for sale.");
        require(msg.value >= nft.price, "Insufficient funds sent.");

        // Transfer NFT to the buyer
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        // Transfer payment to the seller
        payable(nft.owner).transfer(msg.value);

        // Remove the NFT from the list
        delete nfts[tokenId];
    }
}
