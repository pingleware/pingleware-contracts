// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Owned.sol";

contract Destructible is Owned {
    constructor() payable { }

    function destroy() public okOwner {
        selfdestruct(payable(getOwner()));
    }
    
    function destroyAndSend(address _recipient) public okOwner {
        selfdestruct(payable(_recipient));
    }
}