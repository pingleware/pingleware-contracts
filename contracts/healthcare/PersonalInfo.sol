
// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

// See https://github.com/luigidarco96/HealthcareEnabledBlockchain



import "../common/Version.sol";
import "../common/Owned.sol";
import "../libs/User.sol";
import "../libs/StringUtils.sol";

contract PersonalInfo is Version, Owned {

    string public constant DEFAULT_ADMIN_ROLE = string("ADMIN_ROLE98765");
    string public constant PATIENT_ROLE = string("PATIENT_ROLE98765");

    // Record count
    uint public recordCount = 0;

    struct Record {
        uint id;
        uint SpO2; // blood oxygenation
        uint HR; // heart rate
        uint Systolic; // blood pressure - systolic
        uint Diastolic; // blood pressure = diastolic
        address owner; // owner's address, patient
        uint256 timestamp;
    }

    // List of records
    mapping(uint => Record) public records;

    constructor()
    {
        User.addUserByAddress(msg.sender);
        User.updateUserMeta("", "", "", "", "", DEFAULT_ADMIN_ROLE);
        User.updateUserMeta("", "", "", "", "", PATIENT_ROLE);
    }

    // Return `true` if the account belongs to the admin role.
    function isAdmin(address account)
        public
        virtual
        returns (bool)
    {
        return User.hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    // Return `true` if the account belongs to the patient role.
    function isPatient(address account)
        public
        virtual
        returns (bool)
    {
        return User.hasRole(PATIENT_ROLE, account);
    }

    // Restricted to members of the admin role.
    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Restricted to admins.");
        _;
    }

    // Restricted to members of the patient role.
    modifier onlyPatient() {
        require(isPatient(msg.sender), "Restricted to patient.");
        _;
    }

    // Add an account to the user role. Restricted to admins.
    function addPatient(address account)
        public
        virtual
        onlyAdmin
    {
        User.grantRole(PATIENT_ROLE, account);
    }

    // Add an account to the admin role. Restricted to admins.
    function addAdmin(address account)
        public
        virtual
        onlyAdmin
    {
        User.grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    // Remove an account from the patient role. Restricted to admins.
    function removePatient(address account)
        public
        virtual
        onlyAdmin
    {
        User.revokeRole(PATIENT_ROLE, account);
    }

    // Remove oneself from the admin role.
    function renounceAdmin()
        public
        virtual
    {
        User.renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Insert a record in the list
    function createRecord(uint256 _timestamp, uint _spO2, uint _hr, uint _systolic, uint _diastolic)
        public
        virtual
        onlyPatient
    {
        recordCount++;
        records[recordCount] = Record(recordCount, _spO2, _hr, _systolic, _diastolic, msg.sender, _timestamp);
    }

    // Read a record from the list
    function getRecord(uint _id)
        public
        view
        returns (uint, uint, uint, uint, uint, address, uint256)
    {
        Record memory currentRecord = records[_id];
        return (currentRecord.id,
                currentRecord.SpO2,
                currentRecord.HR,
                currentRecord.Systolic,
                currentRecord.Diastolic,
                currentRecord.owner,
                currentRecord.timestamp);
    }
}