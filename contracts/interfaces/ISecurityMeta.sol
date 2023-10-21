// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/**
 * DUE TO SIZE LIMITATIONS ON CONTRACT BYTECODE, CUSIPool WAS CREATED TO MAINTAIN AN ACTIVE
 * RECORD OF SEUCIRTY TOKENS CUSIP ASSIGNED NUMBERS
 */

interface ISecurityMeta {
    function assignCUSIPtoToken(address tokenAddress,string calldata cusipNumber) external;
    function getCUSIP(address tokenAddress) external view returns (string memory);
    function assignISINtoToken(address tokenAddress,string calldata isinNumber) external;
    function getISIN(address tokenAddress) external view returns (string memory);
    function assignFileNumber(address tokenAddress,string calldata secFileNumber) external;
    function getFileNumber(address tokenAddress) external view returns (string memory);
    function assignCertificateNumber(address tokenAddress,uint256 index,string calldata certificateNumber) external;
    function getCertificateNumber(address tokenAddress,uint256 index) external view returns (string memory);
}