// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../interfaces/IAccessControl.sol";

abstract contract AAccessControl is IAccessControl {

    address private owner;

    // Variable to track reentrant calls
    bool private reentrantGuard;


    event Sender(address _sender);

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier isContract(address _contract) {
        require (_contract == address(this),"not authorized contract");
        _;
    }

    modifier validDestination( address to ) {
        require(to != address(0x0));
        require(to != address(this) );
        _;
    }

    modifier nonReentrant() {
        require(!reentrantGuard, "Reentrant call detected");
        reentrantGuard = true;
        _;
        reentrantGuard = false;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

}
