// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

contract SocialNetwork {
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
    address commentor;
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
  mapping (address => Comment[]) private comments;
  mapping (address => LikesDislikes[]) private likes;
  mapping (address => LikesDislikes[]) private dislikes;
  mapping (address => UserMeta) private user_meta;
  mapping (address => uint256) private balances;

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

  constructor()
  {
    name = "MyKronee Token";
    symbol = "MYK";
    _owner = msg.sender;
    _totalSupply = 0;
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
    isUser(msg.sender)
    returns (string memory)
  {
    if (msg.sender == _owner) {
      return string("owner");
    } else if (users[msg.sender] != 0) {
      return string("user");
    } else if (advertisers[msg.sender] != 0) {
      return string("adveriser");
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
    userNotExist
  {
    require(allowance(msg.sender, address(this)) >= 0.001 ether, "registration cost 0.001 ether");
    require(transferFrom(msg.sender, address(this),  0.001 ether));
    users[msg.sender] = 1;
    _users.push(msg.sender);
  }

  function addPost(string memory message)
    public
    payable
    addressValid
    returns (uint256)
  {
    posts[msg.sender].push(message);
    return posts[msg.sender].length - 1;
  }

  function addComment(address poster, uint index, string memory message)
    public
    payable
    addressValid
    isUser(poster)
    isUser(msg.sender)
  {
    Comment memory comment = Comment(msg.sender, index, message);
    comments[poster].push(comment);
  }

  /**
   * interests is comma dellimited string
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
    LikesDislikes memory like = LikesDislikes(post, poster, user);
    likes[user].push(like);
  }

  function setDislike(uint256 post, address poster, address user)
    public
    payable
    isUser(user)
    isUser(poster)
  {
    LikesDislikes memory like = LikesDislikes(post, poster, user);
    dislikes[user].push(like);
  }

  function getLikes(address user)
    public
    view
    isUser(user)
    returns (LikesDislikes[] memory)
  {
    return likes[user];
  }

  function getDislikes(address user)
    public
    view
    isUser(user)
    returns (LikesDislikes[] memory)
  {
    return dislikes[user];
  }
}
