// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Earning potential:
 *
 * Owner/Contract:
 *  - earns from user and advertiser registration
 *  - earns from user posting
 *  - earns from advertiser posting
 *  - earns from user list
 *
 * User:
 *  - earns from comments, friend requests, follower, message notification as a friend and follower, likes and dislikes on posts and comments
 *
 * Advertiser:
 *  - earns from the sale of the product or service in their advertisement
 */

import "../common/Version.sol";
import "../common/Owned.sol";
import "../libs/User.sol";
import "../common/Frozen.sol";
import "../libs/StringUtils.sol";
import "./Advertiser.sol";
import "./SocialFeed.sol";
import "./FriendsFollowers.sol";
import "./Comment.sol";
import "./LikesDislikes.sol";

contract SocialNetwork is Version, Owned, Frozen {

    event ContractCallback(address sender);

    string public constant SOCIAL_NETWORK_NAME = "MyKronee";
    string public constant SOCIAL_NETWORK_TAGLINE = "My Kronee, My Friend!";

    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);

    bool private initialized;

    event ContractFrozen(address sender);
    event ContractThawed(address sender);
    event FallbackEvent(address sender, uint256 amount);
    event ReceiveEvent(address sender, uint256 amount);
    event CashOut(address owner, uint256 amount);

    event MessageUser(address sender, address user, string message);

    mapping (address => uint256) private balances;
    // optout mapping is made public to comply with DO-NOT-CALL legislation
    mapping (address => bool) public optout;

    address public payable_address;
    bool    public active = false;

    constructor()
        payable
    {
        User.addUser();
        User.addUserMeta(SOCIAL_NETWORK_NAME,"","","","",string("Owner"));
        payable_address = msg.sender;
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
        require(StringUtils.equal(User.getUserRole(), User.USER_ROLE),"authorized only for a user");
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
        require(tx.origin == msg.sender, "phishing attack detected?");
        emit FallbackEvent(msg.sender,msg.value);
    }

    receive()
        external
        payable
    {
        emit ReceiveEvent(msg.sender,msg.value);
    }

    function freeze(bytes32 encrypted, bytes memory signature)
        payable
        public
        onlyOwner(encrypted,signature)
    {
        stop();
        active = false;
        emit ContractFrozen(msg.sender);
    }

    function unfreeze(bytes32 encrypted, bytes memory signature)
        payable
        public
        onlyOwner(encrypted,signature)
    {
        start();
        active = true;
        emit ContractThawed(msg.sender);
    }

    /**
     * Registration, advertisement and posting fees are made payable to the contract address.
     * The owner will have to withdraw and pay taxes on the earnings from these fees.
     * This method permits an authenticated cash out of the contract balance to the contract owner.
     *
     * The comment, friend, followers, likes and dislike fees are paid to the originating user at the time
     * of the event. The user is responsible for reporting earnings.
     */
    function cashoutToOwner(bytes32 encrypted, bytes memory signature)
        public
        payable
        onlyOwner(encrypted,signature)
    {
        require(address(this).balance > 0,"no balance to transfer to owner");
        uint256 balance = address(this).balance;
        payable(getOwner()).transfer(balance);
        emit CashOut(getOwner(),balance);
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

        if (StringUtils.equal(role, User.OWNER_ROLE) ||
            StringUtils.equal(role, User.ADVERTISER_ROLE) ||
            StringUtils.equal(role, User.USER_ROLE) ||
            StringUtils.equal(role, User.VERIFIER_ROLE))
        {
            User.updateUserMetaByAddress(_useraddress,fullname,profession,location,dob,interests,role);
            if (StringUtils.equal(role, User.ADVERTISER_ROLE)) {
                Advertiser.addAdvertiser(_useraddress);
            }
        } else {
            revert("unrecognized role");
        }
    }

    function deleteUser(address _useraddress, string memory role, bytes32 encrypted, bytes memory signature)
        public
        payable
        isRunning
        onlyOwner(encrypted,signature)
    {
        require(_useraddress != ZERO_ADDRESS, "missing user address");
        require(User.isUser(_useraddress) == false,"user already exists");
        User.revokeRole(role,_useraddress);
    }

    function blockUser(address _useraddress,string memory role,bytes32 encrypted, bytes memory signature)
        public
        payable
        isRunning
        onlyOwner(encrypted,signature)
    {
        require(_useraddress != ZERO_ADDRESS, "missing user address");
        require(User.isUser(_useraddress) == false,"user already exists");
        User.renounceRole(role,_useraddress);
    }

    function unblockUser(address _useraddress,string memory role,bytes32 encrypted, bytes memory signature)
        public
        payable
        isRunning
        onlyOwner(encrypted,signature)
    {
        require(_useraddress != ZERO_ADDRESS, "missing user address");
        require(User.isUser(_useraddress) == false,"user already exists");
        User.restoreRole(role, _useraddress);
    }

    function registerAdvertiser(string memory fullname, string memory location,string memory dob)
        public
        payable
        isRunning
        addressValid
        advertiserNoExist
    {
        require(msg.value == 0.01 ether,"insufficient registration amount, requires 0.01 ether!");
        //payable(address(this)).transfer(msg.value);
        User.addUser();
        User.updateUserMeta(fullname,string("Advertiser"),location,dob,string("advertising"),User.ADVERTISER_ROLE);
        Advertiser.addAdvertiser(msg.sender);
    }
    

    function register(string memory fullname, string memory profession, string memory location, string memory dob, string memory interests)
        public
        payable
        isRunning
        addressValid
        userNotExist
    {
        require(msg.value == 0.001 ether,"insufficient registration amount, requires 0.001 ether!");
        //payable(address(this)).transfer(msg.value);
        User.addUser();
        User.updateUserMeta(fullname,profession,location,dob,interests,User.USER_ROLE);
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
    {
        require(msg.value == 0.001 ether,"insufficient posting amount, requires 0.001 ether!");
        payable(address(this)).transfer(msg.value);
        uint index = SocialFeeds.addPostv2(timestamp, visibility, message);
        emit SocialFeeds.PostAdded(msg.sender,message,index);
    }

    function adminDeletePost(address poster, uint index,bytes32 encrypted, bytes memory signature)
        public
        payable
        isRunning
        onlyOwner(encrypted,signature)
    {
        SocialFeeds.removePost(poster, index);
    }

    function deletePost(uint index)
        public
        payable
        isRunning
        addressValid
        isUser
    {
        SocialFeeds.removePostByUser(index);
    }

    /**
     * The post owner gets a fee for all comments added to the post, pays 0.0001 ether per post
     */
    function addComment(address poster, uint index, string memory message)
        public
        payable
        isRunning
        addressValid
        isUser
    {
        require(msg.value == 0.0001 ether,"insufficient comment posting amount, requires 0.0001 ether!");
        if (User.isBackupWithholding(poster)) {
            // poster (receiver) is subject to backup withholding, so keep a running balance, transfer to contract address
            payable(address(this)).transfer(msg.value);
            balances[poster] += msg.value;
        } else {
            payable(poster).transfer(msg.value);
        }
        Comment.addComment(poster,index,message);
    }

    function adminDeleteComment(address _useraddress,uint index, bytes32 encrypted, bytes memory signature)
        public
        payable
        isRunning
        onlyOwner(encrypted,signature)
    {
        Comment.deleteComment(_useraddress,index);
    }

    function deleteComment(uint index)
        public
        payable
        isRunning
        addressValid
        isUser
    {
        Comment.deleteCommentByUser(index);
    }

    function getUsers()
        public
        view
        returns (address[] memory)
    {
        return User.getUsers();
    }

    function getAdvertisers()
        public
        view
        returns (address[] memory)
    {
        return Advertiser.getAdvertisers();
    }

    function newAdvertisement(string memory message)
        public
        payable
        isRunning
    {
        require(Advertiser.isAdvertiser(),"unauthorized, not an advertiser");
        require(msg.value == 0.01 ether,"insufficient amount? friend request fee is 0.01 ether");
        payable(address(this)).transfer(msg.value);
        Advertiser.newAdvertisement(message);
    }

    function adminDeleteAdvertisement(address _advertiseraddress, uint index, bytes32 encrypted, bytes memory signature)
        public
        isRunning
        onlyOwner(encrypted,signature)
    {
        Advertiser.deleteAdvertisement(_advertiseraddress,index);
    }

    function deleteAdvertisement(uint index)
        public
        payable
        isRunning
        addressValid
    {
        require(Advertiser.isAdvertiser(),"unauthorized, not an advertiser");
        Advertiser.deleteAdvertisement(msg.sender, index);
    }

    function getAdvertisements()
        public
        view
        returns (string[] memory)
    {
        return Advertiser.getAdvertisements();
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

    function getRoleOfUser(address useraddress)
        public
        view
        returns (string memory)
    {
        return User.getUserRoleByAddress(useraddress);
    }

    /**
     * When you follow a user, you are sending a small compensation to the user as a thank you.
     * User earns 0.0001 ether per each new follower
     */
    function addFollower(address user)
        public
        payable
        isRunning
        addressValid
        isUser
        canPayFee
    {
        require(StringUtils.equal(User.getUserRoleByAddress(user), User.USER_ROLE), "user is not valid");
        require(msg.value == 0.0001 ether,"insufficient amount? follower fee is 0.0001 ether");

        if (User.isBackupWithholding(user)) {
            // poster (receiver) is subject to backup withholding, so keep a running balance, transfer to contract address
            payable(address(this)).transfer(msg.value);
            balances[user] += msg.value;
        } else {
            payable(user).transfer(msg.value); // send a small compensation to the user you are following
        }
        FriendsFollowers.addFollower(user);
    }

    function getFollowers()
        public
        view
        isRunning
        addressValid
        isUser
        returns (address[] memory)
    {
        return FriendsFollowers.getFollowers();
    }

    /**
     * User earns 0.0001 ether per each new friend request. Only friends can comment on a user's posts
     */
    function makeFriendRequest(address user)
        public
        payable
        isRunning
        addressValid
        isUser
        canPayFee
    {
        require(StringUtils.equal(User.getUserRoleByAddress(user), User.USER_ROLE), "user is not valid");
        require(msg.value == 0.0001 ether,"insufficient amount? friend request fee is 0.0001 ether");

        if (User.isBackupWithholding(user)) {
            // poster (receiver) is subject to backup withholding, so keep a running balance, transfer to contract address
            payable(address(this)).transfer(msg.value);
            balances[user] += msg.value;
        } else {
            payable(user).transfer(msg.value); // send a small compensation to the user you are following
        }
        FriendsFollowers.addFriendRequest(user);
    }

    function adminDeleteFollower(address _useraddress,address _followeraddress, bytes32 encrypted, bytes memory signature)
        public
        isRunning
        onlyOwner(encrypted,signature)
    {
        FriendsFollowers.removeFollower(_useraddress,_followeraddress);
    }

    function deleteFollower(address _followeraddress)
        public
        payable
        isRunning
        addressValid
        isUser
    {
        FriendsFollowers.removeFollower(msg.sender,_followeraddress);
    }

    function getFriendRequests()
        public
        view
        isRunning
        addressValid
        isUser
        returns (address[] memory)
    {
        return FriendsFollowers.getFriendRequest();
    }

    function approveFriendRequest(address requestor)
        public
        payable
        isRunning
        addressValid
        isUser
    {
        FriendsFollowers.approveFriendRequest(requestor);
    }

    function deleteFriendRequest(address requestor)
        public
        payable
        isRunning
        addressValid
        isUser
    {
        FriendsFollowers.deleteFriendRequest(requestor);
    }

    /**
     * User sends 0.0001 ether to each follower; 
     */
    function notifyFollowers(string memory message)
        public
        payable
        isRunning
        addressValid
        isUser
    {
        uint256 totalFolloweres = FriendsFollowers.getTotalFollowers();
        require(msg.value == totalFolloweres * 0.0001 ether,"insufficient follower notification fee");
        FriendsFollowers.notifyFollowers(message);
    }

    function notifyFriends(string memory message)
        public
        payable
        isRunning
        addressValid
        isUser
    {
        uint256 totalFriends = FriendsFollowers.getTotalFriends();
        require(msg.value == totalFriends * 0.0001 ether,"insufficient friend notification fee");
        FriendsFollowers.notifyFriends(message);
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

    function myBalance()
        public
        view
        isUser
        returns (uint256)
    {
        return msg.sender.balance;
    }

    /**
     * User pays small gas fee to change opt-out status
     */
    function userChangeOptsOutStatus(address user, bool status)
        public
    {
      optout[user] = status;
    }

    /**
     * Permits third party marketers to send messages to consumers via the connected DAPP for a fee paid to a verified consumer.
     * Consumer has option to opt-out, if they choose to receive communication, they can now get paid for each message received.
     *
     * Since no Personal Identifying Information (PII) is linked to the wallet on the public chain, there is no matching demographics and
     * just plain blind advertising which is most email campaigns.
     */
    function sendUserMessage(address user, string memory message)
      public
      payable
      addressValid
    {
      require(optout[user] == false,"consumer has opted-out to received any external messages or communication");
      require(user != ZERO_ADDRESS,"invalid consumer address");
      require(msg.value == 0.0001 ether,"insufficient message amount, requires 0.0001 ether!");
      payable(user).transfer(0.0001 ether);
      emit MessageUser(msg.sender,user,message);
    }

    /**
     * A marketer can buy the consumer list of wallet addresses. No PII is attached and no demographics.
     * Though a marketer can query the blockchain for matching transactions and develop their own demographics?
     * The next analytic metric?
     */
    function getUserList()
      public
      payable
      addressValid
      returns (address[] memory)
    {
      require(msg.value == 0.001 ether,"insufficient user list amount, requires 0.001 ether!");
      payable(address(this)).transfer(0.001 ether);
      return User.getUsers();
    }
}
