// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Securities.sol";

library Shares {
    struct Security {
        string class;
        uint256 shares;
        uint256 max_ppu;
        uint256 max_aggregate;
        uint256 fee;
        uint256 totalSupply;
    }

    struct ShareStorage {
        mapping (address => string)     CUSIP;
        mapping (address => string)     ISIN;
        mapping (address => uint256)    parValue;
        mapping (address => bool)       restricted;
        mapping (address => uint256)    authorized;
        mapping (address => uint256)    outstanding;

        mapping (address => string)     class;
        mapping (address => uint256)    shares;
        mapping (address => uint256)    max_ppu;
        mapping (address => uint256)    max_aggregate;
        mapping (address => uint256)    fee;
        mapping (address => uint256)    totalSupply;

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

    function getClass(address _contract)
        internal
        view
        returns (string memory)
    {
        return shareStorage().class[_contract];
    }

    function setClass(address _contract,string memory _class)
        internal
    {
        shareStorage().class[_contract] = _class;
    }

    function getShares(address _contract)
        internal
        view
        returns (uint256)
    {
        return shareStorage().shares[_contract];
    }

    function getMaxPPU(address _contract)
        internal
        view
        returns (uint256)
    {
        return shareStorage().max_ppu[_contract];
    }

    function getMaxAggregate(address _contract)
        internal
        view
        returns (uint256)
    {
        return shareStorage().max_aggregate[_contract];
    }

    function getFee(address _contract)
        internal
        view
        returns (uint256)
    {
        return shareStorage().fee[_contract];
    }

    function getTotalSupply(address _contract)
        internal
        view
        returns (uint256)
    {
        return shareStorage().totalSupply[_contract];
    }


    function isPriceBelowParValue(address _contract, uint amount)
        internal
        view
        returns (bool)
    {
      return (amount > shareStorage().parValue[_contract]);
    }

    function getTotalAuthorized(address _contract)
        internal
        view
        returns (uint256)
    {
        return (shareStorage().authorized[_contract]);
    }

    function getOutstanding(address _contract)
        internal
        view
        returns (uint256)
    {
        return (shareStorage().outstanding[_contract]);
    }

    function addOutstanding(address _contract, uint256 amount)
        internal
    {
        shareStorage().outstanding[_contract] += amount;
    }

    function subOutstanding(address _contract, uint256 amount)
        internal
    {
        shareStorage().outstanding[_contract] -= amount;
    }

    function isRestrictedSecurity(address _contract)
        internal
        view
        returns (bool)
    {
      return (shareStorage().restricted[_contract]);
    }

    function assignCUSIP(address _contract, string memory cusip)
        internal
    {
        shareStorage().CUSIP[_contract] = cusip;
    }

    function assignISIN(address _contract, string memory isin)
        internal
    {
        shareStorage().ISIN[_contract] = isin;
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