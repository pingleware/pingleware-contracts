// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";
import "../Owned.sol";
import "../User.sol";
import "../Frozen.sol";
import "../StringUtils.sol";
import "./Advertiser.sol";
import "./SocialFeed.sol";
import "./FriendsFollowers.sol";
import "./Comment.sol";

contract SocialNetwork is Version, Owned, Frozen {

    string public constant OWNER_ROLE = string("Owner");
    string public constant ADVERTISER_ROLE = string("Advertiser");
    string public constant USER_ROLE = string("User");

    string public constant SOCIAL_NETWORK_NAME = "MyKronee";
    string public constant SOCIAL_NETWORK_TAGLINE = "My Kronee, My Friend!";

    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);

    bool private initialized;
    uint256 public _totalSupply;

    event UserRegistered(address sender);
    event NewAdvertiserRegistered(address sender);
    event NewUserPost(address sender, string message);
    event CommentAdded(address sender,address user,string comment);
    event AdvertiserAdded(address sender);
    event Transfer(address sender,address recipient,uint256 amount);
    event Approval(address sender,address recipient,uint256 amount);
    event FallbackEvent(address sender, uint256 amount);
    event ReceiveEvent(address sender, uint256 amount);

    mapping(address => uint256) private _balances;
    mapping(address => mapping (address => uint256)) allowed;
    mapping (address => uint256) private balances;

    constructor()
        payable
    {
        User.addUser();
        User.updateUserMeta(SOCIAL_NETWORK_NAME,"","","","",string("Owner"));
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
        require(StringUtils.equal(User.getUserRole(), USER_ROLE),"authorized only for a user");
        _;
    }

    modifier userNotExist() {
        require(User.notUser(msg.sender), "user exists");
        _;
    }

    modifier advertiserNoExist() {
        require(Advertiser.notAdvertiser(), "advertiser exists");
        _;
    }

    // @notice Will receive any eth sent to the contract
    // https://ethereum.stackexchange.com/questions/42995/how-to-send-ether-to-a-contract-in-truffle-test
    // https://www.codegrepper.com/code-examples/whatever/Expected+a+state+variable+declaration.+If+you+intended+this+as+a+fallback+function+or+a+function+to+handle+plain+ether+transactions%2C+use+the+%22fallback%22+keyword+or+the+%22receive%22+keyword+instead.
    fallback()
        external
        payable
    {
        emit FallbackEvent(msg.sender,msg.value);
    }

    receive()
        external
        payable
    {
        emit ReceiveEvent(msg.sender,msg.value);
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

    function addUser(address _useraddress,string memory fullname, string memory profession, string memory location,
                     string memory dob, string memory interests,
                     string memory role,bytes32 encrypted, bytes memory signature)
        public
        payable
        isRunning
        onlyOwner(encrypted,signature)
    {
        require(_useraddress != ZERO_ADDRESS, "missing user address");
        require(User.isUser(_useraddress) == false,"user already exists");
        User.addUserByAddress(_useraddress);

        if (StringUtils.equal(role, OWNER_ROLE) ||
            StringUtils.equal(role, ADVERTISER_ROLE) ||
            StringUtils.equal(role, USER_ROLE))
        {
            User.updateUserMetaByAddress(_useraddress,fullname,profession,location,dob,interests,role);
            if (StringUtils.equal(role, ADVERTISER_ROLE)) {
                Advertiser.addAdvertiser(_useraddress);
            }
        } else {
            revert("unrecognized role");
        }
    }

    function registerAdvertiser(string memory fullname, string memory location,string memory dob)
        public
        payable
        isRunning
        addressValid
        userNotExist
        advertiserNoExist
    {
        require(msg.value == 0.01 ether,"insufficient amount? advertiser registration fee is 0.01 ether");
        payable(address(this)).transfer(msg.value);
        User.addUser();
        User.updateUserMeta(fullname,string("Advertiser"),location,dob,string("advertising"),ADVERTISER_ROLE);
        Advertiser.addAdvertiser(msg.sender);
        emit NewAdvertiserRegistered(msg.sender);
    }

    function register(string memory fullname, string memory profession, string memory location, string memory dob, string memory interests)
        public
        payable
        isRunning
        addressValid
        userNotExist
    {
        require(msg.value == 0.001 ether,"insufficient amount? registration fee is 0.001 ether");
        payable(address(this)).transfer(msg.value);
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
        require(msg.value == 0.001 ether,"insufficient amount? posting fee is 0.001 ether");
        payable(address(this)).transfer(msg.value);
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
        require(StringUtils.equal(User.getUserRoleByAddress(poster), USER_ROLE), "user is not valid");
        require(msg.value == 0.0001 ether,"insufficient amount? comment posting fee is 0.0001 ether");
        payable(poster).transfer(msg.value);
        Comment.addComment(poster,index,message);
    }

    function getUsers(bytes32 encrypted, bytes memory signature)
        public
        onlyOwner(encrypted,signature)
        returns (address[] memory)
    {
        return User.getUsers();
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
        returns (string memory)
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
        require(StringUtils.equal(User.getUserRoleByAddress(user), USER_ROLE), "user is not valid");
        require(msg.value == 0.0001 ether,"insufficient amount? follower fee is 0.0001 ether");
        payable(user).transfer(msg.value); // send a small compensation to the user you are following
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
        require(StringUtils.equal(User.getUserRoleByAddress(user), USER_ROLE), "user is not valid");
        require(msg.value == 0.0001 ether,"insufficient amount? friend request fee is 0.0001 ether");
        payable(user).transfer(msg.value); // send a small compensation to the user you are following
        FriendsFollowers.addFriendRequest(user);
    }

    /**
     * Payments
     */
    function balanceOf(address account)
        public
        view
        returns (uint256)
    {
        return account.balance;
    }
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return  (_totalSupply - allowed[owner][spender]);
    }

    function transfer(address recipient, uint256 amount)
        public
        returns (bool)
    {
        require(recipient != ZERO_ADDRESS, "missing recipient address");
        if (balances[msg.sender] >= amount && amount > 0 && balances[recipient] + amount > balances[recipient]) { 
            balances[msg.sender] -= amount;
            balances[recipient] += amount;
            emit Transfer(msg.sender, recipient, amount); // trigger event
            return true;
        } else { 
            return false;
        }
    }
    function approve(address spender, uint256 amount)
        public
        returns (bool)
    {
        require(spender != ZERO_ADDRESS, "missing sender address");
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount)
        public
        returns (bool)
    {
        require(sender != ZERO_ADDRESS, "missing sender address");
        require(recipient != ZERO_ADDRESS, "missing recipient address");

        if (balances[sender] >= amount && allowed[sender][msg.sender] >= amount && amount > 0 && balances[recipient] + amount > balances[recipient]) {
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
        } else {
        return false;
        } 
    }     
}
