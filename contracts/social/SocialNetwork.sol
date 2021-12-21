// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

contract SocialNetwork {
    string constant public VERSION = "1.0.4";

    string public name;
    string public symbol;
    uint256 public _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping (address => uint256)) allowed;

    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);

    address public _owner;
    bool private initialized;

    struct Comment {
        address comment_author;
        uint256 post_index;
        string  message;
    }

    struct UserMeta {
        string profession;
        string location;
        string dob;
        string interests;
    }

    struct LikesDislikes {
        uint256 post;
        address poster;
        address user;
    }

    mapping (address => uint256) private users;
    mapping (address => string[]) private posts;
    address[] private _posters;
    mapping (address => Comment[]) private comments;
    address[] private comment_keys;
    mapping (address => mapping(address => uint256)) private likes;
    mapping (address => mapping(address => uint256)) private dislikes;
    mapping (address => UserMeta) private user_meta;
    mapping (address => uint256) private balances;
    mapping (address => address) private followers;
    mapping (address => mapping(address => bool)) private friend_request;
    mapping (address => address) private friends;

    address[] private _friends;

    address[] private _users;


    // advertisers
    mapping (address => uint256) private advertisers;
    address[] private _advertisers;
    mapping (address => string) private advertisements;

    //uint256 public totalSupply = 0;
    mapping(uint256 => address) internal tokens;
    event Mint(address indexed _to, uint256 indexed _tokenId, bytes32 _ipfsHash);

    event Transfer(address sender,address recipient,uint256 amount);
    event Approval(address sender,address spender,uint256 amount);

    event CommentAdded(address sender,address user,string comment);
    event AdvertiserAdded(address sender);
    event UserAdded(address sender);
    event PostAdded(address sender, string message);
    event FollowerAdded(address sender, address follower);
    event FriendRequestAdded(address sender, address user);

  constructor()
    payable
  {
  }
    modifier onlyOwner() {
        require(msg.sender == _owner, "access denied for owner");
        _;
    }

    modifier addressValid() {
        require(msg.sender != address(0), "missing address");
        _;
    }

    modifier userNotExist() {
        require(users[msg.sender] == 0, "user exists");
        _;
    }

    modifier isUser(address user) {
        require(users[user] != 0,"user does not exist");
        _;
    }

    modifier notUser(address user) {
        require(users[user] == 0,"user already exists");
        _;
    }

    modifier isAdvertiser() {
        require(advertisers[msg.sender] != 0, "not an advertiser");
        _;
    }

    modifier notAdvertiser() {
        require(advertisers[msg.sender] == 0, "is an advertiser");
        _;
    }

    function getContractBalance()
        public
        view
        onlyOwner
        returns (uint256)
    {
        return address(this).balance;
    }

    function getOwner()
        public
        view
        returns (address)
    {
        return _owner;
    }

    function getUserRole()
        public
        view
        returns (string memory)
    {
        if (msg.sender == _owner) {
        return string("owner");
        } else if (users[msg.sender] != 0) {
        return string("user");
        } else if (advertisers[msg.sender] != 0) {
        return string("advertiser");
        }
        return string("unknown");
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        returns (uint256)
    {
        return _balances[account];
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

        if (balances[sender] >= amount && allowed[sender][msg.sender] >= amount && amount > 0 &&
        balances[recipient] + amount > balances[recipient]) {
            balances[sender] -= amount;
            balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            return true;
        } else {
            return false;
        }
    }

    function addUser()
        public
        payable
        addressValid
    {
        require(users[msg.sender] == 0,"user already exists");
        users[msg.sender] = 1;
        _users.push(msg.sender);
        emit UserAdded(msg.sender);
        if (msg.sender != _owner) {
            transferFrom(msg.sender, address(this),  0.001 ether);
        }
    }

    function addPostByOwner(string memory message)
        public
        onlyOwner
    {
        posts[msg.sender].push(message);
    }

    function addPost(string memory message)
        public
        payable
        addressValid
        returns (uint256)
    {
        bool found = false;
        if (_posters.length > 0) {
            for (uint i = 0; i < _posters.length; i++) {
                if (_posters[i] == ZERO_ADDRESS) {
                    found = true;
                }
            }
        }
        if (!found) {
            _posters.push(msg.sender);
        }
        posts[msg.sender].push(message);
        emit PostAdded(msg.sender, message);
        return posts[msg.sender].length - 1;
    }

    function getTotalPosts()
        public
        view
        returns (uint256)
    {
        return posts[msg.sender].length;
    }
    
    function getPosts(uint256 index)
        public
        view
        returns (string memory)
    {
        require(index < posts[msg.sender].length,"post does not exists");
        return posts[msg.sender][index];
    }
    

    function getAllPosts()
        public
        view
        onlyOwner
        returns (string memory)
    {
        string memory output = "";
        uint256 total = _posters.length;
        for (uint i = 0; i < total; i++) {
            address key = _posters[i];
            string[] memory post = posts[key];
            if (post.length > 0) {
                for (uint l = 0; l < post.length; l++) {
                    output = string(abi.encodePacked(output, post[l]));
                }
            }
        }
        return output;
    }

    function addComment(address poster, uint index, string memory message)
        public
        payable
        addressValid
        isUser(poster)
        isUser(msg.sender)
    {
        bool found = false;
        if (comment_keys.length > 0) {
            for (uint i = 0; i < comment_keys.length; i++) {
                if (comment_keys[i] == poster) {
                found = true;
                }
            }
        }
        if (!found) {
            comment_keys.push(poster);
        }
        address comment_author = msg.sender;
        Comment memory comment = Comment(comment_author, index, message);
        comments[poster].push(comment);
        emit CommentAdded(msg.sender,poster,message);
    }

    function getCommentTotal(address poster)
        public
        view
        returns (uint256)
    {
        return comments[poster].length;
    }

    function getComment(address poster, uint256 index)
        public
        view
        addressValid
        isUser(msg.sender)
        returns (string memory)
    {
        return string(abi.encodePacked(comments[poster][index].post_index,comments[poster][index].comment_author,comments[poster][index].message));
    }

    function getCommentsForPoster(address poster)
        public
        view
        addressValid
        isUser(msg.sender)
        returns (string memory)
    {
        string memory output = "";
        uint count = comments[poster].length;
        if (count > 0) {
            for(uint i = 0; i < count; i++) {
                output = string(abi.encodePacked(output, "[", comments[poster][i].post_index,comments[poster][i].comment_author,comments[poster][i].message, "]"));
            }
        }
        return output;
    }

    function getAllComments()
        public
        view
        onlyOwner
        returns (string memory)
    {
        string memory output = "";
        uint total = comment_keys.length;
        if (total > 0) {
        for (uint i = 0; i < total; i++) {
            address poster = comment_keys[i];
            uint count = comments[poster].length;
            if (count > 0) {
            output = string(abi.encodePacked(output, "{", poster, ":"));
            for (uint j = 0; j < count; j++) {
                output = string(abi.encodePacked(output, "[", comments[poster][j].post_index,comments[poster][j].comment_author,comments[poster][j].message, "]"));
            }
            output = string(abi.encodePacked(output,"}"));
            }
        }
        }
        return output;
    }

    /**
    * interests is comma dellimited string, e.g. "girls,technology,stage plays"
    */
    function updateUserMeta(string memory profession, string memory location, string memory dob, string memory interests)
        public
        payable
    {
        UserMeta memory meta = UserMeta(profession, location, dob, interests);
        user_meta[msg.sender] = meta;
    }

    // Add a new advertiser
    function addAdvertiser()
        public
        payable
        addressValid
    {
        advertisers[msg.sender] = 1;
        _advertisers.push(msg.sender);
        emit AdvertiserAdded(msg.sender);
    }

    function newAdvertisement(string memory message)
        public
        payable
        isAdvertiser
    {
        advertisements[msg.sender] = message;
    }

    function getAdvertisers()
        public
        view
        onlyOwner
        returns (address[] memory)
    {
        return _advertisers;
    }

    function getUsers()
        public
        view
        onlyOwner
        returns (address[] memory)
    {
        return _users;
    }

    function getTotalUsers()
        public
        view
        returns (uint256)
    {
        return _users.length;
    }

    function getPosters()
        public
        view
        returns (address[] memory)
    {
        return _posters;
    }

    function getTotalPosters()
        public
        view
        returns (uint256)
    {
        return _posters.length;
    }


    /**
    * a post may contain many likes, one -> many
    * one like per user per post
    */
    function setLike(uint256 post, address poster, address user)
        public
        payable
        isUser(user)
        isUser(poster)
    {
        likes[user][poster] = post;
    }

    function setDislike(uint256 post, address poster, address user)
        public
        payable
        isUser(user)
        isUser(poster)
    {
        dislikes[user][poster] = post;
    }

    function getLikes(address user, address poster)
        public
        view
        isUser(user)
        isUser(poster)
        returns (uint256)
    {
        return likes[user][poster];
    }

    function getDislikes(address user, address poster)
        public
        view
        isUser(user)
        isUser(poster)
        returns (uint256)
    {
        return dislikes[user][poster];
    }

    /**
     * Followers
     */
    function addFollower(address user)
        public
        payable
        isUser(msg.sender)
        isUser(user)
    {
        followers[msg.sender] = user;
        emit FollowerAdded(msg.sender, user);
    }

    function getFollowers()
        public
        view
        isUser(msg.sender)
        returns (address)
    {
        return followers[msg.sender];
    }

    // Friend Request
    function addFriendRequest(address user)
        public
        payable
        isUser(msg.sender)
        isUser(user)
    {
        bool found1 = false;
        bool found2 = false;
        for (uint i = 0; i < _friends.length; i++) {
            if (_friends[i] == user) {
                found1 = true;
            }
            if (_friends[1] == msg.sender) {
                found2 = true;
            }
        }
        if (found1) {
            _friends.push(user);
        }
        if (found2) {
            _friends.push(msg.sender);
        }
        friend_request[user][msg.sender] = true;
        friend_request[msg.sender][user] = true;
        emit FriendRequestAdded(msg.sender,user);
    }

    function getTotalFriendRequest()
        public
        view
        returns (uint256)
    {
        uint total = 0;
        for (uint i = 0; i < _friends.length; i++) {
            if (friend_request[msg.sender][_friends[i]]) {
                total++;
            }
        }
        return total;
    }

    function getFriends()
        public
        view
        returns (address[] memory)
    {
        return _friends;
    }

    function getFriendRequest()
        public
        view
        isUser(msg.sender)
        returns (string memory)
    {
        string memory output = "";
        for (uint i = 0; i < _friends.length; i++) {
            if (friend_request[msg.sender][_friends[i]]) {
                output = string(abi.encodePacked(_friends[1]));
            }
        }
        return output;
    }
}
