// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../interfaces/SecuritiesInterface.sol";
import "../interfaces/TransferAgentInterface.sol";

contract Shares {
    enum AssetClass {
        Equity,
        Bonds,
        Commodity,
        RealEstate,
        PreferredStocks,
        MultiAssets,
        Alternatives,
        Volatile,
        Currency
    }

    struct Security {
        AssetClass  class;
        string      FILENUMBER;     // the File Number assigned by the SEC for this offering
        string      CUSIP;
        string      ISIN;
        uint256     parValue;
        uint256     shares;
        bool        restricted;
        uint256     authorized;
        uint256     outstanding;
        uint256     max_ppu;
        uint256     max_aggregate;
        uint256     fee;
        uint256     totalSupply;
    }

    struct ShareStorage {
        mapping (address => Security) securities;
        mapping (address => mapping(address => bytes32)) certificate;
    }

    TransferAgentInterface TransferAgent;

    constructor(address transferagent_contract) {
        TransferAgent = TransferAgentInterface(transferagent_contract);
    }

    function shareStorage()
        internal
        pure
        returns (ShareStorage storage ds)
    {
        bytes32 position = keccak256("share.storage");
        assembly { ds.slot := position }
    }

    function getClass(address offering)
        external
        view
        returns (AssetClass)
    {
        return shareStorage().securities[offering].class;
    }

    function setClass(address offering,AssetClass _class)
        external
    {
        shareStorage().securities[offering].class = _class;
    }

    function getShares(address offering)
        external
        view
        returns (uint256)
    {
        return shareStorage().securities[offering].shares;
    }

    function getMaxPPU(address offering)
        external
        view
        returns (uint256)
    {
        return shareStorage().securities[offering].max_ppu;
    }

    function getMaxAggregate(address offering)
        external
        view
        returns (uint256)
    {
        return shareStorage().securities[offering].max_aggregate;
    }

    function getFee(address offering)
        external
        view
        returns (uint256)
    {
        return shareStorage().securities[offering].fee;
    }

    function getTotalSupply(address offering)
        external
        view
        returns (uint256)
    {
        return shareStorage().securities[offering].totalSupply;
    }

    function addTotalSupply(address offering, uint256 amount)
        external
    {
        shareStorage().securities[offering].totalSupply += amount;
    }


    function isPriceBelowParValue(address offering, uint amount)
        external
        view
        returns (bool)
    {
      return (amount > shareStorage().securities[offering].parValue);
    }

    function getTotalAuthorized(address offering)
        external
        view
        returns (uint256)
    {
        return (shareStorage().securities[offering].authorized);
    }

    function getOutstanding(address offering)
        external
        view
        returns (uint256)
    {
        return (shareStorage().securities[offering].outstanding);
    }

    function addOutstanding(address offering, uint256 amount)
        external
    {
        require(msg.sender != address(0),"invalid transfer agent");
        require(msg.sender  == TransferAgent.getTransferAgent(offering),"not a valid transfer agent");
        shareStorage().securities[offering].outstanding += amount;
    }

    function subOutstanding(address offering, uint256 amount)
        external
    {
        shareStorage().securities[offering].outstanding-= amount;
    }

    function isRestrictedSecurity(address offering)
        external
        view
        returns (bool)
    {
      return (shareStorage().securities[offering].restricted);
    }

    function assignCUSIP(address offering, string memory cusip)
        external
    {
        require(msg.sender != address(0),"invalid transfer agent");
        require(msg.sender  == TransferAgent.getTransferAgent(offering),"not a valid transfer agent");
        shareStorage().securities[offering].CUSIP = cusip;
    }

    function assignISIN(address offering,  string memory isin)
        external
    {
        require(msg.sender != address(0),"invalid transfer agent");
        require(msg.sender  == TransferAgent.getTransferAgent(offering),"not a valid transfer agent");
        shareStorage().securities[offering].ISIN = isin;
    }

    function saveCertificate(address offering,address investor, bytes32 image)
        external
    {
        require(msg.sender != address(0),"invalid transfer agent");
        require(msg.sender  == TransferAgent.getTransferAgent(offering),"not a valid transfer agent");
        shareStorage().certificate[offering][investor] = image;
    }

    function setParValue(address offering, uint256 value)
        external
    {
        require(msg.sender != address(0),"invalid transfer agent");
        require(msg.sender == TransferAgent.getTransferAgent(offering),"not a valid transfer agent");
        shareStorage().securities[offering].parValue = value;
    }

    function getParValue(address offering)
        external
        view
       returns (uint256)
    {
        return shareStorage().securities[offering].parValue;
    }

    function setRestricted(address offering, bool value)
        external
    {
        require(msg.sender != address(0),"invalid transfer agent");
        require(msg.sender == TransferAgent.getTransferAgent(offering),"not a valid transfer agent");
        shareStorage().securities[offering].restricted = value;
    }
}