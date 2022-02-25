/**
 * Built using https://www.thetokenlauncher.com/buildtoken
 * Created as an Equity Token on the above platform.
 * 
 * Deployed on ROPSTEN at https://ropsten.etherscan.io/tx/0xdaf03801e0899b2daceb8c4b3cf7724f74d522d645ef3fff02ebae276c579e52
 *
 * On Token Tracker at https://ropsten.etherscan.io/token/0x39db214c0373eda0eeee10bbf3fdc49a7faec46d
 *
 */
// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * [{"inputs":[],"stateMutability":"payable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"tokenOwner","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint256","name":"tokens","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"tokens","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[],"name":"_totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"tokenOwner","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"remaining","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"tokens","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"tokenOwner","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"balance","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_amount","type":"uint256"}],"name":"burn","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_amount","type":"uint256"}],"name":"mint","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokens","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokens","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"}]
 */

import "../../common/IERC20TOKEN.sol";
import "../../libs/SafeMath.sol";

contract PRESSPAGEENTERTAINMENTINCPRIVATEEQUITY506B is IERC20TOKEN {
    string public constant DESCRIPTION = string("Private Equity Token for PressPage Entertainment Inc (SEC File #021-332144) under Rule 506b at https://www.sec.gov/Archives/edgar/data/0001766947/000176694719000001/xslFormDX01/primary_doc.xml. FOR ACCREDITED INVESTORS ONLY.");
    string public constant CUSIP = string("TO BE ASSIGNED");
    uint256 public constant YEAR = 365 days;
    uint public constant MAX_NONACCREDITED_INVESTORS = 35;

    string public name;
    string public symbol;
    uint8  public decimals;

    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    mapping(address => uint256) transfer_log;
    mapping(address => bool) whitelisted;
    address[] accredited_investors;
    address[] nonaccredited_investors;

    
    constructor() {
        name = "PRESSPAGE ENTERTAINMENT INC PRIVATE EQUITY 506B";
        symbol = "PRESSPAGE.506B.EQUITY"; // Maximum 11 characters
        decimals = 0;
        owner = msg.sender;
        whitelisted[owner] = true;
        _totalSupply = 100 * 10 ** uint256(decimals);   // 24 decimals
        balances[msg.sender] = _totalSupply;
    }

    modifier isAuthorized() {
        require(whitelisted[msg.sender],"not authorized");
        _;
    }

    function addInvestor(address investor, bool accredited)
        public
    {
        require(msg.sender == owner,"only for owner access");
        require(whitelisted[investor] == false,"investor already exists");
        whitelisted[investor] = true;
        if (accredited) {
            accredited_investors.push(investor);
        } else {
            require(nonaccredited_investors.length <= MAX_NONACCREDITED_INVESTORS, "maximum number of non-accredited investors has been reached");
            nonaccredited_investors.push(investor);
        }
    }
    
    /**
     * @dev allowance : Check approved balance
     */
    function allowance(address tokenOwner, address spender) virtual override public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    /**
     * @dev approve : Approve token for spender
     */ 
    function approve(address spender, uint tokens) virtual override public isAuthorized returns (bool success) {
        require(tokens >= 0, "Invalid value");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    /**
     * @dev transfer : Transfer token to another etherum address
     */ 
    function transfer(address to, uint tokens) virtual override public isAuthorized returns (bool success) {
        require(to != address(0), "Null address");  
        require(whitelisted[to],"recipient is not authorized to receive tokens");                                       
        require(tokens > 0, "Invalid Value");
        if (msg.sender != owner) {
            require (block.timestamp >= (transfer_log[msg.sender] + YEAR),"transfer not permitted under Rule 144, holding period has not elapsed");
        }
        transfer_log[to] = block.timestamp;
        balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], tokens);
        balances[to] = SafeMath.safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    /**
     * @dev transferFrom : Transfer token after approval 
     */ 
    function transferFrom(address from, address to, uint tokens) virtual override public isAuthorized returns (bool success) {
        require(to != address(0), "Null address");
        require(from != address(0), "Null address");
        require(whitelisted[to],"recipient is not authorized to receive tokens");
        require(tokens > 0, "Invalid value"); 
        if (from != owner) {
            require (block.timestamp >= (transfer_log[from] + YEAR),"transfer not permitted under Rule 144, holding period has not elapsed");
        }
        require(tokens <= balances[from], "Insufficient balance");
        require(tokens <= allowed[from][msg.sender], "Insufficient allowance");
        transfer_log[to] = block.timestamp;
        balances[from] = SafeMath.safeSub(balances[from], tokens);
        allowed[from][msg.sender] = SafeMath.safeSub(allowed[from][msg.sender], tokens);
        balances[to] = SafeMath.safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    /**
     * @dev totalSupply : Display total supply of token
     */ 
    function totalSupply() virtual override public view returns (uint) {
        return _totalSupply;
    }
    
    /**
     * @dev balanceOf : Displya token balance of given address
     */ 
    function balanceOf(address tokenOwner) virtual override public view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    /**
     * @dev mint : To increase total supply of tokens
     */ 
    function mint(uint256 _amount) public returns (bool) {
        require(_amount >= 0, "Invalid amount");
        require(owner == msg.sender, "UnAuthorized");
        _totalSupply = SafeMath.safeAdd(_totalSupply, _amount);
        balances[owner] = SafeMath.safeAdd(balances[owner], _amount);
        emit Transfer(address(0), owner, _amount);
        return true;
    }
    
     /**
     * @dev mint : To increase total supply of tokens
     */ 
    function burn(uint256 _amount) public returns (bool) {
        require(_amount >= 0, "Invalid amount");
        require(owner == msg.sender, "UnAuthorized");
        require(_amount <= balances[msg.sender], "Insufficient Balance");
        _totalSupply = SafeMath.safeSub(_totalSupply, _amount);
        balances[owner] = SafeMath.safeSub(balances[owner], _amount);
        emit Transfer(owner, address(0), _amount);
        return true;
    }

}