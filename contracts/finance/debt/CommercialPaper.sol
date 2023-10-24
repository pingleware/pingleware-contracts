// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

// Commercial Paper Token with exchange

/**
 * The issuer is the entity issuing the commercial papers. Where the commercial papers are issued through a special purpose vehicle (SPV),
 * the promoter is the entity incorporating the SPV for the purposes of the issuance and holds a significant ownership and control of the SPV,
 * i.e. it is the SPV’s parent company.
 */

/**
 * Licensed Securities Depository
 *
 * The Licensed Securities Depository is a specialist financial institution, licensed by the SEC,
 * which holds commercial papers either in certificated or uncertificated (dematerialized) form so
 * that ownership can be easily transferred through a book entry rather than the transfer of physical certificates.
 * The depository acts as the registrar and the custodian of the commercial papers.
 *
 * A depository is not needed as the commercial paper contract resides on the blockchain amd changes are still made via a book entry
 */

 /**
  * 1. Commercial Paper is issued
  * 2. Promoter or Issuer notifies investors
  * 3. A NRSRO assigns a credit rating to the issuer
  * 4. Investors transfer amount to issuer wallet in multiples of the minimaum denomination, which is typically $100,000
  * 5. During repayment, issuer transfers repayment to the IPA, which  then transfer to the investor. Since a immutable log of transaction is maintain,
  *     the IPA can be eliminated, and repayment comes directly from the issuer wallet.
  */

import "../../common/Version.sol";
import "../../common/Frozen.sol";
import "../../interfaces/IERC20TOKEN.sol";
import "../../libs/SafeMath.sol";


contract CommercialPaper is Version, Frozen, IERC20TOKEN {
    string public constant DESCRIPTION =
        string("Private Debt Token (Commercial Paper) for PressPage Entertainment Inc (SEC File #021-332144) under Rule 506b at https://www.sec.gov/Archives/edgar/data/0001766947/000176694719000001/xslFormDX01/primary_doc.xml. FOR ACCREDITED INVESTORS ONLY.");
    string public constant CUSIP = string("TO BE ASSIGNED");

    uint256 public constant YEAR = 365 days;
    uint256 public constant MAX_SIZE_OF_OFFERING = 5000000; // under 506(b) the maximum is unlimited

    uint public constant MAX_NONACCREDITED_INVESTORS = 35;

    string public name = "Promissary Note for ABC Corporation";
    string public symbol = "ABC.NOTE.S1"; // maximum 11 character
    uint8  public decimals;

    uint256 public _totalSupply;


    uint256 public denomination = 100000; // 36.75 ETH to buy 1 CP token

    struct CommercialPaperInfo {
        address promoter;
        address cra;
        uint256 faceValue;
        uint256 valueDate;
        uint256 maturityDate;
        uint256 discountRate;
        bytes32 status;
        bytes32 creditRating;
    }

    uint256 public exchangeRate = 36750000000; // in GWEI, 1 USD = 370000 GWEI

    CommercialPaperInfo cp;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    mapping(address => uint256) transfer_log;
    mapping(address => bool) whitelisted;
    address[] accredited_investors;
    address[] nonaccredited_investors;

    event CommercialPaperCreated(address pIssuer, uint256 pFaceValue, uint256 pValueDate, uint256 pMaturityDate, uint256 rate);
    event PromoterAssigned(address promoter);
    event CreditReportingAgencyAssigned(address cra);
    event StatusUpdated(address _contract,bytes32 status);
    event InvestorAdded(address investor);
    event ExchangeRateUpdated(uint256 exchangeRate);

    constructor() {
        whitelisted[msg.sender] = true;
        mint(SafeMath.safeDiv(MAX_SIZE_OF_OFFERING, denomination) * 10 ** uint256(decimals));
    }

    modifier isAuthorized() {
        require(whitelisted[msg.sender],"not authorized");
        _;
    }

    function addPromoter(address _promoter)
        public
        okOwner
    {
        require(_promoter != address(0),"invalid address");
        cp.promoter = _promoter;
        emit PromoterAssigned(_promoter);
    }

    function addCreditReportingAgency(address _cra)
        public
        okOwner
    {
        require(_cra != address(0),"invalid address");
        cp.cra = _cra;
        emit CreditReportingAgencyAssigned(_cra);
    }
    
    function addInvestor(address investor, bool accredited)
        public
        okOwner
    {
        require(whitelisted[investor] == false,"investor already exists");
        whitelisted[investor] = true;
        if (accredited) {
            accredited_investors.push(investor);
        } else {
            require(nonaccredited_investors.length <= MAX_NONACCREDITED_INVESTORS, "maximum number of non-accredited investors has been reached");
            nonaccredited_investors.push(investor);
        }
        emit InvestorAdded(investor);
    }

    function updateExchangeRate(uint256 _swapRate)
        public
        okOwner
    {
        exchangeRate = _swapRate;
        emit ExchangeRateUpdated(exchangeRate);
    }
    
    function commercialPaper(uint256 pFaceValue, uint256 pValueDate, uint256 pMaturityDate, uint256 rate)
        public
        okOwner
    {
        require(pMaturityDate <= 270 days,"maturity date extends beyond the acceptable time of 270 days or less");
        cp = CommercialPaperInfo(address(0), address(0), pFaceValue, pValueDate, pMaturityDate, rate, "created","unrated");
        emit CommercialPaperCreated(msg.sender, pFaceValue, pValueDate, pMaturityDate, rate);
    }
    
    function getContractAddress()
        public
        view
        returns(address)
    {
        return address(this);
    }

   
    function updateStatus(bytes32 pStatus)
        public
        okOwner
    {
        cp.status = pStatus;
        emit StatusUpdated(address(this),pStatus);
    }

    function getContract()
        public
        view
        returns(address,address,address,address,uint256,uint256,uint256,uint256,bytes32,bytes32)
    {
        return (address(this),owner,cp.promoter,cp.cra,cp.faceValue,cp.valueDate,cp.maturityDate,cp.discountRate,cp.status,cp.creditRating);
    }

    function buy()
        public
        payable
    {
        // Ensure sender wallet is valid, non-zero
        require(msg.sender != address(0), "zero wallets not accepted");
        require(whitelisted[msg.sender] == true,"investor not permitted to buy this security");
        uint256 tokenAmount = SafeMath.safeDiv(msg.value, SafeMath.safeMul(denomination, exchangeRate));
        require(_totalSupply >= tokenAmount, "excessive purchase amount request");
        approve(msg.sender, tokenAmount);
        transferFrom(payable(address(this)), msg.sender, tokenAmount);
    }

    function sell()
        public
        payable
    {
        // Ensure sender wallet is valid, non-zero
        require(msg.sender != address(0), "zero wallets not accepted");
        require(whitelisted[msg.sender] == true,"investor not permitted to buy this security");
         // Ensure sender balance has enough tokens
        require(balances[msg.sender] >= msg.value, "insufficient token balance");
        uint etherAmount = SafeMath.safeMul(msg.value, exchangeRate);
        require(address(this).balance >= etherAmount, "insufficient balance to send ether");
        payable(msg.sender).transfer(etherAmount);
        approve(address(this), etherAmount);
        // otherwise, transfer to contract
        transferFrom(msg.sender, payable(address(this)), etherAmount);
    }

    /**
     * @dev allowance : Check approved balance
     */
    function allowance(address tokenOwner, address spender)
        public
        virtual
        override
        view
        returns (uint remaining)
    {
        return allowed[tokenOwner][spender];
    }

    /**
     * @dev approve : Approve token for spender
     */
    function approve(address spender, uint tokens)
        public
        virtual
        override
        isAuthorized
        returns (bool success)
    {
        require(tokens >= 0, "Invalid value");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    /**
     * @dev transfer : Transfer token to another etherum address
     */
    function transfer(address to, uint tokens)
        public
        virtual
        override
        isAuthorized
        returns (bool success)
    {
        require(to != address(0), "Null address");
        require(whitelisted[to],"recipient is not authorized to receive tokens");
        require(tokens > 0, "Invalid Value");
        if (msg.sender != owner) {
            require (block.timestamp >= (transfer_log[msg.sender] + YEAR),
                "transfer not permitted under Rule 144, holding period has not elapsed");
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
    function transferFrom(address from, address to, uint tokens)
        public
        virtual
        override
        isAuthorized
        returns (bool success)
    {
        require(to != address(0), "Null address");
        require(from != address(0), "Null address");
        require(whitelisted[to],"recipient is not authorized to receive tokens");
        require(tokens > 0, "Invalid value");
        if (from != owner && to != owner) {
            require (block.timestamp >= (transfer_log[from] + YEAR),
                "transfer not permitted under Rule 144, holding period has not elapsed");
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
    function totalSupply()
        public
        virtual
        override
        view
        returns (uint)
    {
        return _totalSupply;
    }

    /**
     * @dev balanceOf : Displya token balance of given address
     */
    function balanceOf(address tokenOwner)
        public
        virtual
        override
        view
        returns (uint balance)
    {
        return balances[tokenOwner];
    }

    /**
     * @dev mint : To increase total supply of tokens
     */
    function mint(uint256 _amount)
        public
        okOwner
        returns (bool)
    {
        require(_amount >= 0, "Invalid amount");
        _totalSupply = SafeMath.safeAdd(_totalSupply, _amount);
        balances[owner] = SafeMath.safeAdd(balances[owner], _amount);
        emit Transfer(address(0), owner, _amount);
        return true;
    }

     /**
     * @dev mint : To increase total supply of tokens
     */
    function burn(uint256 _amount)
        public
        okOwner
        returns (bool)
    {
        require(_amount >= 0, "Invalid amount");
        require(_amount <= balances[msg.sender], "Insufficient Balance");
        _totalSupply = SafeMath.safeSub(_totalSupply, _amount);
        balances[owner] = SafeMath.safeSub(balances[owner], _amount);
        emit Transfer(owner, address(0), _amount);
        return true;
    }
}