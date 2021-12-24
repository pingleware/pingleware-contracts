// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Securities.sol";

library Shares {
    struct ShareStorage {
        mapping (address => string) CUSIP;
        mapping (address => uint256) parValue;
        mapping (address => bool) restricted;
        mapping (address => mapping(address => bytes32)) certificate;
    }
    
    function shareStorage()
        internal
        pure
        returns (ShareStorage storage ds)
    {
        bytes32 position = keccak256("share.storage");
        assembly { ds.slot := position }
    }


    function isPriceBelowParValue(address _contract, uint amount)
        internal
        view
        returns (bool)
    {
      return (amount > shareStorage().parValue[_contract]);
    }

    function isRestrictedSecurity(address _contract)
        internal
        view
        returns (bool)
    {
      return (shareStorage().restricted[_contract]);
    }

    function assignedCUSIP(address _contract, string memory cusip)
        internal
    {
        shareStorage().CUSIP[_contract] = cusip;
    }

    function saveCertificate(address _contract,address investor, bytes32 image)
        internal
    {
        shareStorage().certificate[_contract][investor] = image;
    }

    function setParValue(address _contract, uint256 value)
        internal
    {
        shareStorage().parValue[_contract] = value;
    }

    function getParValue(address _contract)
        internal
        view
       returns (uint256)
    {
        return shareStorage().parValue[_contract];
    }

    function setRestricted(address _contract, bool value)
        internal
    {
        shareStorage().restricted[_contract] = value;
    }
}