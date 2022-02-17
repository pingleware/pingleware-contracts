// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./StringUtils.sol";

library User {
    string public constant OWNER_ROLE = string("Owner");
    string public constant ADVERTISER_ROLE = string("Advertiser");
    string public constant USER_ROLE = string("User");
    string public constant VERIFIER_ROLE = string("Verifier");
    string public constant CONSUMER_ROLE = string("Consumer");
    string public constant CREDITOR_ROLE = string("Creditor");
    string public constant COLLECTION_AGENT_ROLE = string("Collection Agent");

    struct UserMeta {
        string  fullname;
        string  profession;
        string  location;
        string  dob;
        string  interests;
        string  role;
        bool    backup_withholding;
        bool    verified;
    }

    /**
     * The user's are scoped by the contract address which they are associated
     */
    struct UserStorage {
        mapping (address => uint256) users;
        address[] _users;
        mapping (address => UserMeta) user_meta;
        address contract_address;
    }

    function userStorage() internal pure returns (UserStorage storage ds)
    {
        bytes32 position = keccak256("user.storage");
        assembly { ds.slot := position }
    }

    event UserAdded(address sender);
    event UserMetaUpdated(address sender,string fullname,string profession,string location,string dob,string interests,string role);
    event UserDeleted(address useraddress);
    event UserBlocked(address useraddress);
    event UserRoleRestored(address useraddress,string role);
    event ErrorOccurred(string reason);

    function userNotExist()
        external
        view
        returns (bool)
    {
        return (userStorage().users[msg.sender] == 0);
    }

    function isUser(address user)
        external
        view
        returns (bool)
    {
        return (userStorage().users[user] != 0);
    }

    function notUser(address user)
        external
        view
        returns (bool)
    {
        return (userStorage().users[user] == 0);
    }

    function addUser()
        external
    {
        require(userStorage().users[msg.sender] == 0,"user already exists");
        userStorage().users[msg.sender] = 1;
        userStorage()._users.push(msg.sender);
        emit UserAdded(msg.sender);
    }

    function addUserByAddress(address _useraddress)
        external
    {
        require(StringUtils.equal(userStorage().user_meta[msg.sender].role, OWNER_ROLE),"unauthorized access, sender not an owner");
        require(userStorage().users[_useraddress] == 0,"user already exists");
        userStorage().users[_useraddress] = 1;
        userStorage()._users.push(_useraddress);
    }

    function getUsers()
        external
        view
        returns (address[] memory)
    {
        return userStorage()._users;
    }

    function getTotalUsers()
        external
        view
        returns (uint256)
    {
        return userStorage()._users.length;
    }

    /**
    * interests is comma dellimited string, e.g. "girls,technology,stage plays"
    * use keccak256 to convert a string role to bytes32
    */
    function updateUserMeta(string memory fullname, string memory profession, string memory location, string memory dob, string memory interests, string memory role)
        external
    {
        require(StringUtils.equal(userStorage().user_meta[msg.sender].role, OWNER_ROLE) ||
                StringUtils.equal(userStorage().user_meta[msg.sender].role, ADVERTISER_ROLE) ||
                StringUtils.equal(userStorage().user_meta[msg.sender].role, USER_ROLE) ||
                StringUtils.equal(userStorage().user_meta[msg.sender].role, CONSUMER_ROLE) ||
                StringUtils.equal(userStorage().user_meta[msg.sender].role, CREDITOR_ROLE) ||
                StringUtils.equal(userStorage().user_meta[msg.sender].role, COLLECTION_AGENT_ROLE),
                "unauthorized access");

        UserMeta memory meta = UserMeta(fullname, profession, location, dob, interests, role, false, false);
        userStorage().user_meta[msg.sender] = meta;
        emit UserMetaUpdated(msg.sender,fullname, profession, location, dob, interests, role);
    }

    function addUserMeta(string memory fullname, string memory profession, string memory location, string memory dob, string memory interests, string memory role)
        external
    {
        require(msg.sender != address(0x0),"invalid user address");
        UserMeta memory meta = UserMeta(fullname, profession, location, dob, interests, role, false, false);
        userStorage().user_meta[msg.sender] = meta;
        emit UserMetaUpdated(msg.sender,fullname, profession, location, dob, interests, role);
    }

    function updateUserMetaByAddress(address _useraddress, string memory fullname, string memory profession, string memory location, string memory dob, string memory interests, string memory role)
        external
    {
        require(StringUtils.equal(userStorage().user_meta[msg.sender].role, OWNER_ROLE),"unauthorized access, sender not an owner");
        UserMeta memory meta = UserMeta(fullname, profession, location, dob, interests, role, false, false);
        userStorage().user_meta[_useraddress] = meta;
    }

    function verifyUser(address _user)
        external
    {
        require(StringUtils.equal(userStorage().user_meta[msg.sender].role, VERIFIER_ROLE),"unauthorized access, sender not a verifier");
        require(_user != address(0x0),"invalid user address");
        require(userStorage().users[_user] != 0,"user does not exist");
        userStorage().user_meta[_user].verified = true;
    }

    function getUserMeta()
        external
        view
        returns (UserMeta memory)
    {
        return userStorage().user_meta[msg.sender];
    }

    function getUserRole()
        external
        view
        returns (string memory)
    {
        return userStorage().user_meta[msg.sender].role;
    }

    function getUserRoleByAddress(address _useraddress)
        external
        view
        returns (string memory)
    {
        return userStorage().user_meta[_useraddress].role;
    }

    function hasRole(string memory role, address _useraddress)
        external
        view
        returns (bool)
    {
        return (StringUtils.equal(userStorage().user_meta[_useraddress].role,role));
    }

    function grantRole(string memory role, address _useraddress)
        external
    {
        require(userStorage().users[_useraddress] == 0,"user already exists");
        userStorage().users[_useraddress] = 1;
        userStorage()._users.push(_useraddress);
        UserMeta memory meta = UserMeta("", "", "", "", "", role, false,false);
        userStorage().user_meta[_useraddress] = meta;
    }

    function revokeRole(string memory role, address _useraddress)
        external
    {
        require(userStorage().users[_useraddress] != 0,"user does not exists");
        require(StringUtils.equal(userStorage().user_meta[_useraddress].role, role),"role does not match");
        delete userStorage().users[_useraddress];
        delete userStorage().user_meta[_useraddress];
        emit UserDeleted(_useraddress);
    }

    function renounceRole(string memory role, address _useraddress)
        external
    {
        require(StringUtils.equal(userStorage().user_meta[_useraddress].role, role),"role does not match");
        userStorage().user_meta[_useraddress].role = string("UNDEFINED_ROLE");
        emit UserBlocked(_useraddress);
    }

    function restoreRole(string memory role, address _useraddress)
        external
    {
        require(StringUtils.equal(userStorage().user_meta[_useraddress].role, role),"role does not match");
        userStorage().user_meta[_useraddress].role = role;
        emit UserRoleRestored(_useraddress,role);
    }

    /**
     * Required by the IRS for US-based wallets, when a notification is received from the IRS that a wallet address is
     * subject to backup withholding?
     */
    function changeBackupWithholding(address _useraddress,bool backup_withholding)
        external
    {
        userStorage().user_meta[_useraddress].backup_withholding = backup_withholding;
    }

    function isBackupWithholding(address _useraddress)
        external
        view
        returns (bool)
    {
        return userStorage().user_meta[_useraddress].backup_withholding;
    }
}