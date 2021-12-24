// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./ecverify.sol";

abstract contract Owned {
    uint256 constant public WAIT = 30 seconds;

    address private owner;

    uint256 private previous_block_timestamp = 0;

    constructor()
        payable
    {
        owner = msg.sender;
        previous_block_timestamp = block.timestamp;
    }

    modifier rateLimitCheck() {
        require (block.timestamp > previous_block_timestamp + WAIT, "rate limit error");
        _;
    }

    /**
     * Solving the onlyOwner sppofing: 
     * using web3.eth.sign() to generate a signed hash of the owner address and passing the hash and signature to this method
     *
     */
    modifier onlyOwner(bytes32 encrypted, bytes memory signature) {
        require (msg.sender == owner, "access denied for owner"); // WARNING: this can be spoofed!
        /**
         * FIX: Issue #1
         *
         * only the owner who created the contract will be able to provide a valid hash-signature
         */
        require (ECVerify.ecverify(encrypted, signature, owner), "access denied, owner not valid");
        _;
    }

    modifier isOwner(address addr, bytes32 encrypted, bytes memory signature) {
        require (addr == owner, "owner access denied for user"); // WARNING: this can be spoofed!
        /**
         * FIX: Issue #1
         *
         * only the owner who created the contract will be able to provide a valid hash-signature
         */
        require (ECVerify.ecverify(encrypted, signature, owner), "access denied, owner not valid");
        _;
    }

    function getOwner()
        public
        payable
        rateLimitCheck
        returns (address)
    {
        require (block.timestamp > previous_block_timestamp + WAIT, "rate limit error");
        previous_block_timestamp = block.timestamp;
        return owner;
    }

}