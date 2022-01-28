// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";
import "../Owned.sol";
import "../User.sol";
import "../Frozen.sol";
import "./Advertiser.sol";
import "./SocialFeed.sol";
import "./FriendsFollowers.sol";
import "./Comment.sol";

contract SocialNetwork is Version, Owned, Frozen {

    bytes32 public constant OWNER_ROLE = keccak256("Owner");
    bytes32 public constant ADVERTISER_ROLE = keccak256("Advertiser");
    bytes32 public constant USER_ROLE = keccak256("User");

    string public social_network_name;

    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);

    bool private initialized;

    event UserRegistered(address sender);
    event NewUserPost(address sender, string message);
    event CommentAdded(address sender,address user,string comment);
    event AdvertiserAdded(address sender);


    constructor(string memory _name)
        payable
    {
        social_network_name = _name;
        User.addUser();
        User.updateUserMeta("","","","","",keccak256("Owner"));
    }

    modifier addressValid() {
        require(msg.sender != address(0), "missing address");
        _;
    }

    modifier canPayFee() {
        require(msg.sender.balance > 0.001 ether,"insufficient balance");
        _;
    }

    modifier isUser() {
        require(User.getUserRole() == USER_ROLE,"authorized only for a user");
        _;
    }

    function freeze(bytes32 encrypted, bytes memory signature)
        public
        onlyOwner(encrypted,signature)
    {
        stop();
    }

    function unfreeze(bytes32 encrypted, bytes memory signature)
        public
        onlyOwner(encrypted,signature)
    {
        start();
    }

    function addUser(address _useraddress,string memory fullname, string memory profession, string memory location, string memory dob, string memory interests,
                     bytes32 role,bytes32 encrypted, bytes memory signature)
        public
        payable
        isRunning
        onlyOwner(encrypted,signature)
    {
        require(_useraddress != ZERO_ADDRESS, "missing user address");
        require(User.isUser(_useraddress) == false,"user already exists");
        User.addUserByAddress(_useraddress);

        if (role == OWNER_ROLE || role == ADVERTISER_ROLE || role == USER_ROLE) {
            User.updateUserMetaByAddress(_useraddress,fullname,profession,location,dob,interests,role);
            if (role == ADVERTISER_ROLE) {
                Advertiser.addAdvertiser(_useraddress);
            }
        } else {
            revert("unrecognized role");
        }
    }

    function register(string memory fullname, string memory profession, string memory location, string memory dob, string memory interests)
        public
        payable
        isRunning
        addressValid
        canPayFee
    {
        require(User.isUser(msg.sender) == false,"user already exists");
        payable(address(this)).transfer(0.001 ether);
        User.addUser();
        User.updateUserMeta(fullname,profession,location,dob,interests,USER_ROLE);
        emit UserRegistered(msg.sender);
    }

    /**
     * The contract gets a fee for posting
     */
    function post(uint256 timestamp, bool visibility, string memory message)
        public
        payable
        isRunning
        addressValid
        isUser
        canPayFee
    {
        payable(address(this)).transfer(0.001 ether);
        SocialFeeds.addPostv2(timestamp, visibility, message);
        emit NewUserPost(msg.sender,message);
    }

    /**
     * The post owner gets a fee for all comments added to the post
     */
    function addComment(address poster, uint index, string memory message)
        public
        payable
        isRunning
        addressValid
        isUser
        canPayFee
    {
        require(User.getUserRoleByAddress(poster) == USER_ROLE, "user is not valid");
        payable(poster).transfer(0.0001 ether);
        Comment.addComment(poster,index,message);
    }

    function getContractBalance(bytes32 encrypted, bytes memory signature)
        public
        onlyOwner(encrypted,signature)
        returns (uint256)
    {
        return address(this).balance;
    }

    function getUserRole()
        public
        view
        returns (bytes32)
    {
        return User.getUserRole();
    }

    /**
     * When you follow a user, you are sending a small compensation to the user as a thank you.
     */
    function addFollower(address user)
        public
        payable
        isRunning
        addressValid
        isUser
        canPayFee
    {
        require(User.getUserRoleByAddress(user) == USER_ROLE, "user is not valid");
        payable(user).transfer(0.0001 ether); // send a small compensation to the user you are following
        FriendsFollowers.addFollower(user);
    }

    function makeFriendRequest(address user)
        public
        payable
        isRunning
        addressValid
        isUser
        canPayFee
    {
        require(User.getUserRoleByAddress(user) == USER_ROLE, "user is not valid");
        payable(user).transfer(0.0001 ether); // send a small compensation to the user you are following
        FriendsFollowers.addFriendRequest(user);
    }
}
