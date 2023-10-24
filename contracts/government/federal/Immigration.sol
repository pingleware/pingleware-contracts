// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../../abstract/AAccessControl.sol";

contract Immigration is AAccessControl {
    mapping(address => VisaApplication) public visaApplications;

    struct VisaApplication {
        uint256 applicationDate;
        uint256 processingTime;
        bool approved;
    }

    event ApplicationSubmitted(address applicant);
    event ApplicationProcessed(address applicant, bool approved);


    function submitApplication() public {
        VisaApplication storage application = visaApplications[msg.sender];
        require(application.applicationDate == 0, "Application already submitted");
        application.applicationDate = block.timestamp;
        emit ApplicationSubmitted(msg.sender);
    }

    function processApplication(address applicant, bool approvalStatus) public isOwner {
        VisaApplication storage application = visaApplications[applicant];
        require(application.applicationDate != 0, "Application not found");
        application.processingTime = block.timestamp - application.applicationDate;
        application.approved = approvalStatus;
        emit ApplicationProcessed(applicant, approvalStatus);
    }

    function getApplicationStatus(address applicant) public view returns (bool, uint256) {
        VisaApplication storage application = visaApplications[applicant];
        return (application.approved, application.processingTime);
    }
}