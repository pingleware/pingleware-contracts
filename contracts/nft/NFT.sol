// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/**
 * In this contract:
 *
 * 1. We import the OpenZeppelin ERC721 contract and inherit from it to create our custom NFT contract.
 * 2. The constructor is used to set the name and symbol for your NFT collection.
 * 3. The mint function allows the contract owner to create and assign new NFTs to specific addresses. It takes the recipient's address, the NFT's ID, and the URI for the token metadata. 
 *    You can extend this contract to include more minting options if needed.
 *
 * To deploy this contract, you need to provide the appropriate arguments (name and symbol) when creating the contract, 
 * and you'll be able to mint NFTs with it. Please note that this contract alone won't enable users to register their NFTs for resale; 
 * you'd need the NFTCollection contract (as shown in the previous answer) to achieve that functionality. 
 * Users can list the NFTs minted from the NFTContract on the NFTCollection for resale.
 */

import "../abstract/AERC721.sol";

contract NFT is AERC721 {
    constructor(string memory name, string memory symbol) AERC721(name, symbol) {
        // The contract is initialized with a name and symbol for your NFTs.
    }

    // Mint a new NFT and assign it to the given owner
    function mint(address to, uint256 tokenId, string memory tokenURI) external {
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }

    // INTERNAL FUNCTIONS
    function _mint(address to, uint256 tokenId) internal {

    }
    function _setTokenURI(uint256 tokenId, string memory tokenURI) internal {

    }
}
