// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "./AccessControl.sol";

contract StockCertificate is AccessControl {
    // Struct to represent a certificate
    struct StockCertificateMeta {
        uint256 id;
        string symbol;
        address holder;
        uint256 balance;
    }

    // Mapping from certificate ID to its data
    mapping(address => mapping(uint256 => StockCertificateMeta)) private certificates;

    // Mapping from investor wallet address to a list of certificate IDs they hold
    mapping(address => uint256[]) private investorCertificates;

    uint256 private nextCertificateId = 1; // Next available certificate ID

    // Events to log certificate creation and transfer
    event StockCertificateCreated(uint certificateNumber, address owner, string symbol);
    event StockCertificateTransferred(uint certificateNumber, address from, address to);


    // Function to issue a certificate to an investor
    function issueCertificate(address tokenAddress, string calldata symbol, address _investor, uint256 _initialBalance) external returns(uint256) {
        require(_investor != address(0), "Invalid investor address");
        require(_initialBalance > 0, "Initial balance must be greater than zero");

        // Create a new certificate and add it to the mapping
        certificates[tokenAddress][nextCertificateId] = StockCertificateMeta(nextCertificateId, symbol, _investor, _initialBalance);

        // Add the certificate ID to the investor's list of certificates
        investorCertificates[_investor].push(nextCertificateId);

        // Increment the next available certificate ID
        nextCertificateId++;

        emit StockCertificateCreated((nextCertificateId - 1),_investor,symbol);

        return nextCertificateId - 1;
    }

    // Function to transfer certificates (shares sold) from one investor to another
    function transferCertificate(address from, address tokenAddress, uint256 _certificateId, address _to, uint256 _amount) external  {
        require(_to != address(0), "Invalid recipient address");
        require(_amount > 0, "Amount must be greater than zero");
        require(certificates[tokenAddress][_certificateId].holder == from, "Sender is not the holder of the certificate");
        require(certificates[tokenAddress][_certificateId].balance >= _amount, "Insufficient certificate balance");

        // Update the balances of the sender and recipient
        certificates[tokenAddress][_certificateId].balance -= _amount;
        certificates[tokenAddress][_certificateId].holder = _to;

        // Add the certificate ID to the recipient's list of certificates
        investorCertificates[_to].push(_certificateId);

        emit StockCertificateTransferred(_certificateId,from,_to);
    }

    // Function to check the balance of a specific certificate
    function getCertificateBalance(address tokenAddress, uint256 _certificateId) external view  returns (uint256) {
        return certificates[tokenAddress][_certificateId].balance;
    }

    // Function to retrieve a list of certificate IDs held by an investor
    function getInvestorCertificates(address _investor) external view  returns (uint256[] memory) {
        return investorCertificates[_investor];
    }

    function isCertificateValid(address tokenAddress,address wallet,uint256 _certificateId) external view  returns (bool) {
        return (certificates[tokenAddress][_certificateId].holder == wallet);
    }
}
