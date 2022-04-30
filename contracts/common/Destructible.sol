// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Owned.sol";

contract Destructible is Owned {
    event Destroyed(address sender,address recipient);
    event Termination(address sender,string reason);

    constructor() payable { }

    function destroy() public okOwner {
        emit Destroyed(msg.sender,getOwner());
        selfdestruct(payable(getOwner()));
    }

    function destroyAndSend(address _recipient) public okOwner {
        emit Destroyed(msg.sender,_recipient);
        selfdestruct(payable(_recipient));
    }

    function terminate(bytes32 encrypted, bytes memory signature, string memory reason)
        public
        payable
        onlyOwner(encrypted,signature)
    {
        emit Termination(msg.sender, reason);
        selfdestruct(payable(getOwner()));
    }
}