// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";
import "../common/IERC20TOKEN.sol";
import "../libs/SafeMath.sol";

contract RINS is Version, Owned, IERC20TOKEN {
    string public constant DESCRIPTION = string("");

    string public name;
    string public symbol;
    uint8  public decimals;

    uint256 public _totalSupply;


    struct RINType {
        uint256 vintage;
        uint    dcode;
        uint256 amount;
    }

    // mapped to address of producer and year
    mapping(address => RINType[]) rins;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint256) transfer_log;
    mapping(address => bool) whitelisted;
    mapping(address => bool) producer;
    mapping(address => bool) participator;
    mapping(address => bool) compliance;

    constructor() {
        _totalSupply = 0;
    }

    modifier isProducer() {
        require(producer[msg.sender],"not a producer");
        _;
    }

    modifier isAuthorized() {
        require(participator[msg.sender],"not a participator");
        _;
    }

    modifier isComplianceOfficer() {
        require(compliance[msg.sender],"not a compliance officer");
        _;
    }

    function addProducer(address _producer)
        public
        okOwner
    {
        require(whitelisted[_producer] == false,"investor already exists");
        whitelisted[_producer] = true;
        producer[_producer] = true;
        compliance[_producer] = true;
    }

    function addParticipator(address _participator)
        public
        okOwner
    {
        require(whitelisted[_participator] == false,"investor already exists");
        whitelisted[_participator] = true;
        participator[_participator] = true;
    }

    function addComplianceOfficer(address _officer)
        public
        okOwner
    {
        require(whitelisted[_officer] == false,"investor already exists");
        whitelisted[_officer] = true;
        compliance[_officer] = true;
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


    function mint(uint256 _amount) public payable isProducer returns (bool) {
        require(_amount >= 0, "Invalid amount");
        rins[msg.sender].push(RINType(block.timestamp, msg.value ,_amount));
        balances[msg.sender] = SafeMath.safeAdd(balances[msg.sender],_amount);
        _totalSupply = SafeMath.safeAdd(_totalSupply, _amount);
        emit Transfer(msg.sender, address(this), _amount);
        return true;
    }

    function burn(uint256 _amount) public isComplianceOfficer returns (bool) {
        require(_amount >= 0, "Invalid amount");
        require(_amount <= balances[msg.sender], "Insufficient Balance");
        _totalSupply = SafeMath.safeSub(_totalSupply, _amount);
        balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], _amount);
        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }

}
