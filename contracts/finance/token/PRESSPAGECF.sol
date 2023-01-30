// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Built using https://www.thetokenlauncher.com/buildtoken
 * Created as an Equity Token choosing ICO on the above platform.
 */

import "../../common/IERC20CF.sol";
import "../../libs/SafeMath.sol";

contract PRESSPAGEENTERTAINMENTINCICOCF is IERC20CF {
    string public constant DESCRIPTION = string("Public Offering Token for PressPage Entertainment Inc  under Rule CF. AVAILABLE FOR ANY INVESTOR");
    string public constant CUSIP = string("TO BE ASSIGNED");
    string public constant ISIN = string("TO BE ASSIGNED");

    string public name;
    string public symbol;
    uint256 public decimals; 
    
    uint256 public _totalSupply;
    uint256 public _circulating_supply;
    uint256 public _sold;

    address private feecollectaddress=0x222926cA4E89Dc1D6099b98C663efd3b0f60f474;
    bool public isMinting;
    uint256 public RATE; // must be at least the par value!
    uint256 public Start;
    uint256 public End;
    uint256 total;
    address private referaddr=0x0000000000000000000000000000000000000000;
    uint256 private referamt=0;
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    constructor() payable {
        name = "PRESSPAGE ENTERTAINMENT INC ICO CF";
        symbol = "PRESSPAGES1";
        decimals = 0;
        owner = msg.sender;
        isMinting = true;
        RATE = 1;
        _totalSupply = 200000 * 10 ** uint256(decimals);   // 24 decimals 
        balances[msg.sender] = _totalSupply;
        _circulating_supply = 0;
        _sold=0;
        payable(address(uint160(referamt))).transfer(referamt);
        payable(address(uint160(feecollectaddress))).transfer(SafeMath.safeSub(msg.value,referamt));
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "UnAuthorized");
         _;
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
    
      function circulatingSupply() virtual public view returns (uint) {
        return _circulating_supply;
    }
    
    
     function sold() virtual public view returns (uint) {
        return _sold;
    }
    /**
     * @dev balanceOf : Displya token balance of given address
     */ 
    function balanceOf(address tokenOwner) virtual override public view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    
    function buyTokens(uint256 tokens) payable public {
        if(isMinting==true && Start <= block.timestamp && End >= block.timestamp)
        {
             require(msg.value > 0);
             require(_totalSupply >= _sold,"Token sold");
             uint256 value = SafeMath.safeMul(tokens,RATE);
             value=SafeMath.safeDiv(value,(10**(decimals)));
             require(msg.value==value);
             require(_circulating_supply >= tokens,"Circulating supply not enough");
             payable(address(uint160(owner))).transfer(msg.value);
             _circulating_supply = SafeMath.safeSub(_circulating_supply,tokens);
             _sold=SafeMath.safeAdd(_sold,tokens);
             balances[owner]=SafeMath.safeSub(balances[owner],tokens);
             balances[msg.sender] = SafeMath.safeAdd(balances[msg.sender], tokens);
             if(balances[msg.sender]==tokens){
                  emit Buyerlist(msg.sender);
            }
            emit Transfer(owner,msg.sender, tokens);
              
        }
        else
        {
            revert("isMiniting False");
        }
    }
    
    

    function endCrowdsale() onlyOwner public {
        isMinting = false;
    }

    function changeCrowdsaleRate(uint256 _value) onlyOwner public {
        RATE = _value;
    }
    
    function startCrowdsale(uint256 _fromtime,uint256 _totime,uint256 _rate, uint256 supply) onlyOwner public returns(bool){
        require(SafeMath.safeAdd(_sold,supply) <= _totalSupply, "Token sold issue");
        Start=_fromtime;
        End=_totime;
        RATE=_rate;
        isMinting = true;
        _circulating_supply=SafeMath.safeAdd(_circulating_supply,supply);
        emit startSale(_fromtime,_totime,_rate,supply);
        return true;
    }
    
    function getblocktime() public view returns(uint256)
    {
        return block.timestamp;
    }
    
    function issueDividend(address[] memory addr,uint256[] memory amount) payable public onlyOwner returns(bool){
        require(amount.length > 0,"Enter valid amount");
        for(uint256 i; i < amount.length;i++)
        {
            payable(address(uint160(addr[i]))).transfer(amount[i]);
            emit issueDivi(addr[i],amount[i]);
        }
        return true;
    }
    
     /**
     * @dev burn : To decrease total supply of tokens
     */ 
    function burn(uint256 _amount) public onlyOwner returns (bool) {
        require(_amount >= 0, "Invalid amount");
        require(_amount <= balances[msg.sender], "Insufficient Balance");
        _totalSupply = SafeMath.safeSub(_totalSupply, _amount);
        balances[owner] = SafeMath.safeSub(balances[owner], _amount);
        emit Transfer(owner, address(0), _amount);
        return true;
    }
    
    function mint(uint256 _amount) public onlyOwner returns (bool) {
        require(_amount >= 0, "Invalid amount");
        _totalSupply = SafeMath.safeAdd(_totalSupply, _amount);
         balances[owner] = SafeMath.safeAdd(balances[owner], _amount);
        return true;
    }
 
     receive() external payable {
     revert("Incorrect Function access");
    }


}
