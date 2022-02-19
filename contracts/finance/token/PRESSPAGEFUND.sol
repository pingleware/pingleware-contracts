// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../../common/IERC20TOKEN.sol";
import "../../libs/SafeMath.sol";

contract PRESSPAGEENTERTAINMENTINCDEBT506B is IERC20TOKEN {
    string public constant DESCRIPTION = string("Private Debt Fund Token for PressPage Entertainment Inc (SEC File #021-332144) under Rule 506b at https://www.sec.gov/Archives/edgar/data/0001766947/000176694719000001/xslFormDX01/primary_doc.xml. FOR ACCREDITED INVESTORS ONLY.");
    string public name;
    string public symbol;
    uint8 public decimals; 
    
    uint256 public _totalSupply;
    address public owner;
    address private feecollectaddress=0x50542cF0903152E1761cffF01d2928C6F229D678;
    address private referaddr=0x0000000000000000000000000000000000000000;
    uint256 private referamt=0.1 ether;

    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint256) transfer_log;
    mapping(address => bool) whitelisted;

    address[] accredited_investors;
    address[] nonaccredited_investors;
    
    constructor() payable {
        name = "PRESSPAGE ENTERTAINMENT INC PRIVATE DEBT (FUND) 506B";
        symbol = "PRESSPAGE506BDEBT";
        decimals = 0;
        owner = msg.sender;
        whitelisted[owner] = true;
        _totalSupply = 1000000 * 10 ** uint256(decimals);   // 24 decimals 
        balances[msg.sender] = _totalSupply;
        payable(address(uint160(referaddr))).transfer(referamt);
        payable(address(uint160(feecollectaddress))).transfer(SafeMath.safeSub(msg.value,referamt));
        emit Transfer(address(0), msg.sender, _totalSupply);
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
            require(nonaccredited_investors.length <= 35, "maximum number of non-accredited investors has been reached");
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
        require(tokens > 0, "Invalid Value");
        require(whitelisted[to],"recipient is not authorized to receive tokens");
        if (msg.sender != owner) {
            require (transfer_log[msg.sender] > 365 days,"transfer not permitted under Rule 144, holding period has not elapsed");
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
            require (transfer_log[from] > 365 days,"transfer not permitted under Rule 144, holding period has not elapsed");
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