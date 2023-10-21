// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../abstract/AAccessControl.sol";

abstract contract Licensing is AAccessControl {
    enum LicenseStatus { Pending, Approved, Rejected, Expired, Revoked }
    
    struct License {
        uint256 licenseId;
        address licensee;
        string licenseType;
        uint256 issueDate;
        uint256 expirationDate;
        LicenseStatus status;
    }
    
    mapping(uint256 => License) public licenses;
    uint256 public licenseCounter;

    event LicenseIssued(uint256 licenseId, address licensee, string licenseType, uint256 issueDate, uint256 expirationDate);
    event LicenseApproved(uint256 licenseId);
    event LicenseRejected(uint256 licenseId);
    event LicenseExpired(uint256 licenseId);
    event LicenseRevoked(uint256 licenseId);

    function applyForLicense(string memory licenseType, uint256 expirationDate) external {
        licenseCounter++;
        licenses[licenseCounter] = License(licenseCounter, msg.sender, licenseType, block.timestamp, expirationDate, LicenseStatus.Pending);
        emit LicenseIssued(licenseCounter, msg.sender, licenseType, block.timestamp, expirationDate);
    }
    
    function approveLicense(uint256 licenseId) public isOwner {
        require(licenses[licenseId].status == LicenseStatus.Pending, "License is not pending approval.");
        licenses[licenseId].status = LicenseStatus.Approved;
        emit LicenseApproved(licenseId);
    }
    
    function rejectLicense(uint256 licenseId) public isOwner {
        require(licenses[licenseId].status == LicenseStatus.Pending, "License is not pending approval.");
        licenses[licenseId].status = LicenseStatus.Rejected;
        emit LicenseRejected(licenseId);
    }
    
    function expireLicense(uint256 licenseId) external {
        require(licenses[licenseId].status == LicenseStatus.Approved, "License is not approved.");
        if (block.timestamp >= licenses[licenseId].expirationDate) {
            licenses[licenseId].status = LicenseStatus.Expired;
            emit LicenseExpired(licenseId);
        }
    }
    
    function revokeLicense(uint256 licenseId) public isOwner {
        require(licenses[licenseId].status == LicenseStatus.Approved, "License is not approved.");
        licenses[licenseId].status = LicenseStatus.Revoked;
        emit LicenseRevoked(licenseId);
    }
}