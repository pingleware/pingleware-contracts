// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

interface ITransferAgent {
    function setMaxUnaccreditInvestors(uint256 value) external;
    function addVerified(address addr, string memory hash) external;
    function removeVerified(address addr) external;
    function updateVerified(address addr, string memory hash) external;
    function isSuperseded(address addr) external;
    function holderCount()        external;
    function holderAt(uint256 index)        external;
    function addShareholder(address addr, uint level) external;
    function cancelAndReissue(address original, address replacement) external;
    function toggleExemptOffering(address offering, uint256 timestamp, bool _active) external;
    function allowance(address _owner, address spender) external view returns (uint256);
    function addMinter(address addr) external;
    function addTransferAgent(address offering, address addr) external;
    function getTransferAgent(address offering) external view returns (address);
    function checkTransferAgent(address offering) external view returns (bool);
    
    function mint(address offering, address _to, uint256 _amount, uint256 _epoch, uint256 _initial_supply) external returns(bool);
}
