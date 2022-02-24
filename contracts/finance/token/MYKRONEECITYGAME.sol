/**
 *Submitted for verification at Etherscan.io on 2020-09-04
*/
// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../../common/IERC20TOKEN.sol";
import "../../libs/SafeMath.sol";


contract TheCityofMyKroneeGameToken is IERC20TOKEN {
    string public constant DESCRIPTION = string("A game token for use with the simcity game at MYKRONEE.CITY");

    string public name;
    string public symbol;
    uint8  public decimals; 
    
    uint256 public _totalSupply;

    address private feecollectaddress=0x50542cF0903152E1761cffF01d2928C6F229D678;
    address private referaddr=0x0000000000000000000000000000000000000000;
    uint256 private referamt=0.1 ether;

    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    constructor() payable {
        name = "The City of My Kronee Game Token";
        symbol = "MYKRONEE.CITY";
        decimals = 0;
        owner = msg.sender;
        _totalSupply = 1000000 * 10 ** uint256(decimals);   // 24 decimals 
        balances[msg.sender] = _totalSupply;
        payable(address(uint160(referaddr))).transfer(referamt);
        payable(address(uint160(feecollectaddress))).transfer(SafeMath.safeSub(msg.value,referamt));
        emit Transfer(address(0), msg.sender, _totalSupply);
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
    function approve(address spender, uint tokens) virtual override public returns (bool success) {
        require(tokens >= 0, "Invalid value");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    /**
     * @dev transfer : Transfer token to another etherum address
     */ 
    function transfer(address to, uint tokens) virtual override public returns (bool success) {
        require(to != address(0), "Null address");                                         
        require(tokens > 0, "Invalid Value");
        balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], tokens);
        balances[to] = SafeMath.safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    /**
     * @dev transferFrom : Transfer token after approval 
     */ 
    function transferFrom(address from, address to, uint tokens) virtual override public returns (bool success) {
        require(to != address(0), "Null address");
        require(from != address(0), "Null address");
        require(tokens > 0, "Invalid value"); 
        require(tokens <= balances[from], "Insufficient balance");
        require(tokens <= allowed[from][msg.sender], "Insufficient allowance");
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