// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./SafeMath.sol";
import "./BaseOffering.sol";

abstract contract IOfferingRegAT1 is BaseOffering {
    string public constant DESCRIPTION = string("Exempt Offering under Regulation A Tier 1");
    string public CUSIP = string("TO BE ASSIGNED");
    string public SEC_FILENUMBER = string("024-00000");
    uint256 public MAX_OFFERING = 20000000;
    uint256 public MAX_OFFERING_SHARES = 4000000; // based on the maximum allowance offering and intial share price

    function getMaxOffering() virtual public view returns(uint256);
    function transfer(address to, uint tokens) virtual override public returns (bool success);
    function transferFrom(address from, address to, uint tokens) virtual override public returns (bool success);
    function mint(uint256 _amount) virtual public returns (bool);
    function burn(uint256 _amount) virtual public returns (bool);
    function setCUSIP(string memory cusip) virtual override public;
    function setSECFilenumber(string memory fileNumber) virtual override public;
    function setMaxOffering(uint256 value) virtual override public;
    function setMaxShares(uint256 value) virtual override public;
}