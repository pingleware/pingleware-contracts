// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../../common/Version.sol";
import "../../common/Frozen.sol";
//import "../../common/IERC20TOKEN.sol";
import "../../libs/SafeMath.sol";
import "../equity/DelawareStockToken.sol";

contract PRESSPAGE506C is Version, Frozen, DelawareStockToken {
    string public constant DESCRIPTION = string("Rule 506(c) exempt offering for PressPage Entertainment Inc. FOR ACCREDITED INVESTORS ONLY.");
    string public constant SEC_FILENUMBER = string("021-332144");
    string public constant SEC_URL = string("https://www.sec.gov/Archives/edgar/data/0001766947/000176694722000003/xslFormDX01/primary_doc.xml");

    uint256 public constant YEAR = 365 days; // 365 days holding for non-reporting exempt offering
    uint256 public constant SIXMONTHS = 26 weeks; // six months for reporting companies using an exempt offering

    string public CUSIP = string("TO BE ASSIGNED"); // https://www.cusip.com/apply/
    string public ISIN = string("TO BE ASSIGNED");  // https://www.isin.org/isin-registration/

    //string public name;
       // Apply for a symbol from FINRA using Form 211, see instructions https://www.finra.org/sites/default/files/p126234.pdf
    //string public symbol;
    //uint8  public decimals = 0;

    //uint256 public _totalSupply;

    bool public reportingCompany = false;

    uint256 public holdingTime = YEAR;

    //mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint256) transfer_log;

    address[] private accredited_investors;

    event ReportingStatusChanged(address,bool status);
    event SymbolChanged(address sender,string old_symbol, string new_symbol);
    event CUSIPChanged(address sender,string old_number,string new_number);
    event ISINChanged(address sender,string old_number,string new_number);

    constructor(uint _supply, string memory _hash, address payable _registry)
        DelawareStockToken("PRESS.506CE","PRESSPAGE ENTERTAINMENT INC EXEMPT EQUITY 506(C)",SafeMath.mul(_supply, 10 ** uint256(decimals)),_hash,_registry)
    {
        setTotalSupply(SafeMath.mul(_supply, 10 ** uint256(decimals)));
        addAddressToWhitelist(address(this));
    }

    modifier isAuthorized() {
        require(isWhitelisted(msg.sender),"not authorized");
        _;
    }

    function changeReportingStatus(bool status)
        public
        okOwner
        returns (bool)
    {
        require(status != reportingCompany,"no change in reporting status");
        reportingCompany = status;
        if (reportingCompany) {
            holdingTime = SIXMONTHS;
        } else {
            holdingTime = YEAR;
        }
        emit ReportingStatusChanged(msg.sender,reportingCompany);
        return reportingCompany;
    }

    function resetMetadata()
        public
        okOwner
    {
        CUSIP = "TO BE ASSIGNED";
        ISIN = "TO BE ASSIGNED";
        symbol = "PRESS.506CE";
    }

    function changeCUSIP(string memory _cusip)
        public
        okOwner
        returns (string memory)
    {
        string memory old_cusip = CUSIP;
        CUSIP = _cusip;
        emit CUSIPChanged(msg.sender,old_cusip,CUSIP);
        return CUSIP;
    }

    function changeISIN(string memory _isin)
        public
        okOwner
        returns (string memory)
    {
        string memory old_isin = ISIN;
        ISIN = _isin;
        emit ISINChanged(msg.sender,old_isin,ISIN);
        return CUSIP;
    }

    function changeSymbol(string memory _symbol)
        public
        okOwner
        returns (string memory)
    {
        string memory old_symbol = symbol;
        symbol = _symbol;
        emit SymbolChanged(msg.sender,old_symbol,symbol);
        return symbol;
    }

    /**
     * Only accrdited investors may participate!
     */
    function addInvestor(address investor)
        public
        okOwner
    {
        require(isWhitelisted(investor) == false,"investor already exists");
        addAddressToWhitelist(investor);
        accredited_investors.push(investor);
    }

    function disableInvestor(address investor)
        public
        okOwner
    {
        require(isWhitelisted(investor) == true,"investor does not exists or is already disabled");
        removeAddressFromWhitelist(investor);
    }

   /**
     * @dev allowance : Check approved balance
     */
    function allowance(address tokenOwner, address spender) public virtual override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    /**
     * @dev approve : Approve token for spender
     */
    function approve(address spender, uint tokens) public virtual override isAuthorized returns (bool success) {
        require(tokens >= 0, "Invalid value");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    /**
     * @dev transfer : Transfer token to another etherum address
     */ 
    function transfer(address to, uint tokens) public virtual override isAuthorized returns (bool success) {
        require(to != address(0), "Null address");
        require(isWhitelisted(to),"investor is not authorized to send tokens");
        require(tokens > 0, "Invalid Value");
        // adding to != address(this), permits the investor to transfer their shares back to the contract
        if (msg.sender != getOwner() || to != address(this)) {
            require (block.timestamp >= SafeMath.safeAdd(transfer_log[msg.sender], holdingTime),"transfer not permitted under Rule 144, holding period has not elapsed");
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
    function transferFrom(address from, address to, uint tokens) public virtual override isAuthorized returns (bool success) {
        require(to != address(0), "Null address");
        require(from != address(0), "Null address");
        require(isWhitelisted(to),"investor is not authorized to receive tokens");
        require(tokens > 0, "Invalid value");
        if (from != getOwner() || to != address(this)) {
            require (block.timestamp >= SafeMath.safeAdd(transfer_log[from], holdingTime),"transfer not permitted under Rule 144, holding period has not elapsed");
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
     * @dev balanceOf : Displya token balance of given address
     */
    function balanceOf(address tokenOwner) public virtual override view returns (uint balance) {
        return balances[tokenOwner];
    }

    /**
     * @dev mint : To increase total supply of tokens
     */
    function mint(uint256 _amount) public okOwner returns (bool) {
        require(_amount >= 0, "Invalid amount");
        setTotalSupply(SafeMath.safeAdd(totalSupply(), _amount));
        balances[address(this)] = SafeMath.safeAdd(balances[address(this)], _amount);
        emit Transfer(address(0), address(this), _amount);
        return true;
    }

     /**
     * @dev mint : To increase total supply of tokens
     */
    function burn(uint256 _amount) public okOwner returns (bool) {
        require(_amount >= 0, "Invalid amount");
        require(_amount <= balances[address(this)], "Insufficient Balance");
        setTotalSupply(SafeMath.safeSub(totalSupply(), _amount));
        balances[address(this)] = SafeMath.safeSub(balances[address(this)], _amount);
        emit Transfer(address(this), address(0), _amount);
        return true;
    }

}