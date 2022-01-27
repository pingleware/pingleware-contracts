// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";
import "../Owned.sol";

contract Donation is Version, Owned {

    address[] _giver;



    function donate()
        public
        payable
    {
        if (msg.value == 0) {
            revert("insufficient funds");
        }
        payable(address(this)).transfer(msg.value);
        addGiver(msg.sender);
    }

    function moveFund(bytes32 encrypted,bytes memory signature)
        public
        onlyOwner(encrypted,signature)
    {
      payable(getOwner()).transfer(address(this).balance);
    }


    function addGiver(address _a)
        internal
    {
        _giver.push(_a);
    }
}
