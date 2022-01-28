// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library User {




    struct UserMeta {
        string  fullname;
        string  profession;
        string  location;
        string  dob;
        string  interests;
        bytes32 role;
    }

    struct UserStorage {
        mapping (address => uint256) users;
        address[] _users;
        mapping (address => UserMeta) user_meta;
    }

    function userStorage() internal pure returns (UserStorage storage ds)
    {
        bytes32 position = keccak256("user.storage");
        assembly { ds.slot := position }
    }

    event UserAdded(address sender);

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
    }

    function addUserByAddress(address _useraddress)
        external
    {
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
    */
    function updateUserMeta(string memory fullname, string memory profession, string memory location, string memory dob, string memory interests, bytes32 role)
        external
    {
        UserMeta memory meta = UserMeta(fullname, profession, location, dob, interests, role);
        userStorage().user_meta[msg.sender] = meta;
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
        returns (bytes32)
    {
        return userStorage().user_meta[msg.sender].role;
    }

    function getUserRoleByAddress(address _useraddress)
        external
        view
        returns (bytes32)
    {
        return userStorage().user_meta[_useraddress].role;
    }

    function hasRole(bytes32 role, address _useraddress)
        external
        view
        returns (bool)
    {
        return (userStorage().user_meta[_useraddress].role == role);
    }

    function grantRole(bytes32 role, address _useraddress)
        external
    {
        require(userStorage().users[_useraddress] == 0,"user already exists");
        userStorage().users[_useraddress] = 1;
        userStorage()._users.push(_useraddress);
        UserMeta memory meta = UserMeta("", "", "", "", "", role);
        userStorage().user_meta[_useraddress] = meta;
    }

    function revokeRole(bytes32 role, address _useraddress)
        external
    {
        require(userStorage().users[_useraddress] != 0,"user does not exists");
        require(userStorage().user_meta[_useraddress].role != role,"role does not match");
        delete userStorage().users[_useraddress];
        delete userStorage().user_meta[_useraddress];
    }

    function renounceRole(bytes32 role, address _useraddress)
        external
    {
        require(userStorage().user_meta[_useraddress].role != role,"role does not match");
        userStorage().user_meta[_useraddress].role = keccak256("UNDEFINED_ROLE");
    }
}