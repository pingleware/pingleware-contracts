// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

contract Donation is Version, Owned {

    address[] _giver;



    function donate()
        public
        payable
    {
        if (msg.value == 0) {
            revert("insufficient funds");
        }
        // transfer donation to the contract from the sender (donor)
        payable(address(this)).transfer(msg.value);
        addGiver(msg.sender);
    }

    function moveFund()
        public
        payable
        onlyOwner
    {
      payable(getOwner()).transfer(address(this).balance);
    }


    function addGiver(address _a)
        internal
    {
        _giver.push(_a);
    }
}
