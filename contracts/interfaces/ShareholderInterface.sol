// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

interface ShareholderInterface {
    function setMaxUnaccreditInvestors(address offering, uint256 value) external;
    function addVerified(address addr, string memory hash) external;
    function removeVerified(address addr) external;
    function updateVerified(address addr, string memory hash) external;
    function isSuperseded(address addr) external view returns (bool);
    function isHolder(address addr) external view returns (bool);
    function hasHash(address addr, bytes32 hash) external view returns (bool);
    function holderCount() external view returns (uint);
    function holderAt(uint256 index) external view returns (address);
    function addShareholder(address offering, address addr, uint level) external;
    function updateShareholders(address addr) external;
    function pruneShareholders(address addr, uint256 value) external;
    function cancelAndReissue(address original, address replacement) external returns (address, address);
}