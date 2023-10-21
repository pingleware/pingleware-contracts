// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../interfaces/IERC721.sol";

abstract contract AERC721 is IERC721 {
    string _name;
    string _symbol;
    address _owner;
    uint256 _balance;

    mapping (address => uint256) private token_balances;
    mapping (uint256 => address) private tokens;

    constructor(string memory name,string memory symbol) {
        _name = name;
        _symbol = symbol;
    }

    function balanceOf(address owner) external view returns (uint256 balance) {
        return token_balances[owner];
    }
    function ownerOf(uint256 tokenId) external view returns (address owner) {
        return tokens[tokenId];
    }
    function safeTransferFrom(address from,address to,uint256 tokenId) external {
        require(tokens[tokenId] == from,"not the token owner");
        tokens[tokenId] = to;
    }
    function transferFrom(address from,address to,uint256 tokenId) external {
        require(tokens[tokenId] == from,"not the token owner");
        tokens[tokenId] = to;
    }
    function approve(address to, uint256 tokenId) external {

    }
    function getApproved(uint256 tokenId) external view returns (address operator) {

    }
    function setApprovalForAll(address operator, bool _approved) external {

    }
    function isApprovedForAll(address owner, address operator) external view returns (bool) {

    }
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external {

    }
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

    }
}