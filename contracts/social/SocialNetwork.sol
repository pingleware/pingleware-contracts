// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";
import "../User.sol";
import "./Advertiser.sol";


contract SocialNetwork is Version {

    string public name;
    string public symbol;
    uint256 public _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping (address => uint256)) allowed;

    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);

    address public _owner;
    bool private initialized;

    mapping (address => uint256) private balances;

    //uint256 public totalSupply = 0;
    mapping(uint256 => address) internal tokens;
    event Mint(address indexed _to, uint256 indexed _tokenId, bytes32 _ipfsHash);

    event Transfer(address sender,address recipient,uint256 amount);
    event Approval(address sender,address spender,uint256 amount);
    event FollowerAdded(address sender, address follower);
    event FriendRequestAdded(address sender, address user);
    event CommentAdded(address sender,address user,string comment);
    event AdvertiserAdded(address sender);


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
        } else if (User.isUser(msg.sender)) {
            return string("user");
        } else if (Advertiser.isAdvertiser()) {
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
}
