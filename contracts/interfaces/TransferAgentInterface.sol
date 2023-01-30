// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

interface TransferAgentInterface {
    function setMaxUnaccreditInvestors(uint256 value, bytes32 encrypted, bytes memory signature) external;
    function addVerified(address addr, string memory hash,bytes32 encrypted, bytes memory signature) external;
    function removeVerified(address addr,bytes32 encrypted, bytes memory signature) external;
    function updateVerified(address addr, string memory hash,bytes32 encrypted, bytes memory signature) external;
    function isSuperseded(address addr,bytes32 encrypted, bytes memory signature) external;
    function holderCount(bytes32 encrypted, bytes memory signature)        external;
    function holderAt(uint256 index,bytes32 encrypted, bytes memory signature)        external;
    function addShareholder(address addr, uint level,bytes32 encrypted, bytes memory signature) external;
    function cancelAndReissue(address original, address replacement,bytes32 encrypted, bytes memory signature) external;
    function toggleExemptOffering(address offering, uint256 timestamp, bool _active, bytes32 encrypted, bytes memory signature) external;
    function allowance(address _owner, address spender) external view returns (uint256);
    function addMinter(address addr,bytes32 encrypted, bytes memory signature) external;
    function addTransferAgent(address offering, address addr) external;
    function getTransferAgent(address offering) external view returns (address);
    function checkTransferAgent(address offering, bytes32 encrypted, bytes memory signature) external view returns (bool);
    
    function mint(address offering, address _to, uint256 _amount, uint256 _epoch, uint256 _initial_supply, bytes32 encrypted, bytes memory signature) external returns(bool);
}
