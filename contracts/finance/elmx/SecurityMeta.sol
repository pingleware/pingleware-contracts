// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/**
 * DUE TO SIZE LIMITATIONS ON CONTRACT BYTECODE, CUSIPool WAS CREATED TO MAINTAIN AN ACTIVE
 * RECORD OF SEUCIRTY TOKENS CUSIP ASSIGNED NUMBERS
 */

import "./AccessControl.sol";

contract SecurityMeta is AccessControl {
    mapping (address => string) public CUSIP;
    mapping (address => string) public ISIN;
    mapping (address => string) public FILENUMBER;
    mapping (address => mapping(uint256 => string)) public CERTIFICATE_NUMBER;


    event CUSIPAssigned(address token,string cusip);
    event CUSIPReplaced(address token,string oldCUSIP,string newCUSIP);
    event ISINAssigned(address token,string isin);
    event ISINReplaced(address token,string oldISIN,string newISIN);
    event FILENUMBERAssigned(address token,string fileNumber);
    event FILENUMBERReplaced(address token,string oldFileNumber,string newFileNumber);
    event CERTIFICATENUMBERAssigned(address token,uint256 index,string certificateNumber);
    event CERTIFICATENUMBERReplaced(address token,uint256 index,string oldCertificateNumber,string newCertificateNumber);


    function assignCUSIPtoToken(address tokenAddress,string calldata cusipNumber) external  {
        if (keccak256(abi.encodePacked(CUSIP[tokenAddress])) == keccak256(abi.encodePacked(""))) {
            CUSIP[tokenAddress] = cusipNumber;
            emit CUSIPAssigned(tokenAddress, cusipNumber);
        } else if (keccak256(abi.encodePacked(CUSIP[tokenAddress])) == keccak256(abi.encodePacked(cusipNumber))) {
            string memory oldCUSIP = CUSIP[tokenAddress];
            CUSIP[tokenAddress] = cusipNumber;
            emit CUSIPReplaced(tokenAddress, oldCUSIP, cusipNumber);
        }
    }

    function getCUSIP(address tokenAddress) external view  returns (string memory) {
        return CUSIP[tokenAddress];
    }

    function assignISINtoToken(address tokenAddress,string calldata isinNumber) external  {
        if (keccak256(abi.encodePacked(ISIN[tokenAddress])) == keccak256(abi.encodePacked(""))) {
            ISIN[tokenAddress] = isinNumber;
            emit ISINAssigned(tokenAddress, isinNumber);
        } else if (keccak256(abi.encodePacked(ISIN[tokenAddress])) == keccak256(abi.encodePacked(isinNumber))) {
            string memory oldISIN = ISIN[tokenAddress];
            ISIN[tokenAddress] = isinNumber;
            emit ISINReplaced(tokenAddress, oldISIN, isinNumber);
        }
    }

    function getISIN(address tokenAddress) external view  returns (string memory) {
        return ISIN[tokenAddress];
    }

    function assignFileNumber(address tokenAddress,string calldata secFileNumber) external  {
        if (keccak256(abi.encodePacked(FILENUMBER[tokenAddress])) == keccak256(abi.encodePacked(""))) {
            FILENUMBER[tokenAddress] = secFileNumber;
            emit FILENUMBERAssigned(tokenAddress, secFileNumber);
        } else if (keccak256(abi.encodePacked(FILENUMBER[tokenAddress])) == keccak256(abi.encodePacked(secFileNumber))) {
            string memory oldFileNumber = FILENUMBER[tokenAddress];
            FILENUMBER[tokenAddress] = secFileNumber;
            emit FILENUMBERReplaced(tokenAddress, oldFileNumber, secFileNumber);
        }
    }

    function getFileNumber(address tokenAddress) external view  returns (string memory) {
        return FILENUMBER[tokenAddress];
    }

    function assignCertificateNumber(address tokenAddress,uint256 index,string calldata certificateNumber) external  {
        if (keccak256(abi.encodePacked(CERTIFICATE_NUMBER[tokenAddress][index])) == keccak256(abi.encodePacked(""))) {
            CERTIFICATE_NUMBER[tokenAddress][index] = certificateNumber;
            emit CERTIFICATENUMBERAssigned(tokenAddress, index, certificateNumber);
        } else if (keccak256(abi.encodePacked(CERTIFICATE_NUMBER[tokenAddress][index])) == keccak256(abi.encodePacked(certificateNumber))) {
            string memory oldCertificateNumber = CERTIFICATE_NUMBER[tokenAddress][index];
            CERTIFICATE_NUMBER[tokenAddress][index] = certificateNumber;
            emit CERTIFICATENUMBERReplaced(tokenAddress, index, oldCertificateNumber, certificateNumber);
        }
    }

    function getCertificateNumber(address tokenAddress,uint256 index) external view  returns (string memory) {
        return CERTIFICATE_NUMBER[tokenAddress][index];
    }
}