// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

interface ISecurities {
    function assignedCUSIP(address _contract, string memory cusip) external payable;
    function saveCertificate(address _contract, bytes32 image) external payable;
    function setParValue(address _contract, uint256 value) external payable;
    function setRestricted(address _contract, bool value) external payable;
}