// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Version.sol";
import "./Owned.sol";

contract Whitelistable is Version, Owned {
    mapping (address => bool) public whitelist;
    
    event AddressAddedToWhitelist(address indexed AuthorizedBy, address indexed AddressAdded);
    event AddressRemovedFromWhitelist(address indexed AuthorizedBy, address indexed AddressRemoved);


    constructor() {
    }
    
    function isWhitelisted(address _address) public view returns(bool){ // function to check if address is whitelisted
        return whitelist[_address];
    }

    function addAddressToWhitelist(address _address) okOwner public{ // add an address to the authorized mapping
        require(!isWhitelisted(_address));
        whitelist[_address] = true;
        emit AddressAddedToWhitelist(msg.sender, _address);
    }

    function removeAddressFromWhitelist(address _address) okOwner public{
        require(isWhitelisted(_address)); // check if address is whitelisted
        whitelist[_address] = false;
        emit AddressRemovedFromWhitelist(msg.sender, _address);
    }
}