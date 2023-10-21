// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../abstract/AAccessControl.sol";
import "./Case.sol";


abstract contract Police is AAccessControl, Case {
    enum OfficerRole { Patrol, Detective, SWAT, K9, Forensics, Technician, Corrections }
    
    struct PoliceOfficer {
        string name;
        OfficerRole role;
        bool active;
    }
    
    mapping(address => PoliceOfficer) public officers;

    event OfficerAdded(address officerAddress, string name, OfficerRole role);
    event OfficerUpdated(address officerAddress, OfficerRole newRole);
    event OfficerRemoved(address officerAddress);   

    modifier isOfficer() {
        require(officers[msg.sender].active,"not a valid officer");
        _;
    }

    function issueViolation(address jurisdiction, address offender,string memory violation) external isOfficer returns(string memory) {
        return createCase(jurisdiction, offender, violation);
    }

    function addOfficer(address officerAddress, string memory name, OfficerRole role) public isOwner {
        require(officers[officerAddress].role == OfficerRole(0), "Officer already exists.");
        officers[officerAddress] = PoliceOfficer(name, role, true);
        emit OfficerAdded(officerAddress, name, role);
    }
    
    function updateOfficerRole(address officerAddress, OfficerRole newRole) public isOwner {
        require(officers[officerAddress].role != OfficerRole(0), "Officer does not exist.");
        officers[officerAddress].role = newRole;
        emit OfficerUpdated(officerAddress, newRole);
    }
    
    function removeOfficer(address officerAddress) public isOwner {
        require(officers[officerAddress].role != OfficerRole(0), "Officer does not exist.");
        officers[officerAddress].active = false;
        emit OfficerRemoved(officerAddress);
    }     
}