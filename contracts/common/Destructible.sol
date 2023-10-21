// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Owned.sol";

contract Destructible is Owned {
    event Destroyed(address sender,address recipient);
    event Termination(address sender,string reason);

    constructor() payable { }

    function destroy() public okOwner {
        emit Destroyed(msg.sender,getOwner());
    }

    function destroyAndSend(address _recipient) public okOwner {
        emit Destroyed(msg.sender,_recipient);
    }
}