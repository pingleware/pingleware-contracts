// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.7.0 <0.9.0;

import "../../interfaces/IOfferingInfoInterface.sol";

contract ATS {

    string public TRADING_SYSTEM;

    address public immutable OWNER;

    string[] public symbols;

    struct ATSStorage {
        mapping (address => bool) transferAgent;

        mapping (address => bool) issuers;
        mapping (address => bool) accredited_investors;
        mapping (address => bool) nonaccredited_investors;
        mapping (address => bool) affiliated_investors;
        mapping (address => bool) broker_dealers;

        mapping (address => mapping (string => uint256)) balances;
        mapping (address => mapping (string => IOfferingInfoInterface.OfferingInfo)) offering;
        mapping (address => uint256) fee;

        // liquidity
        uint256 totalLiquidity;
        mapping(address => uint256) liquidity;
    }

    function atsStorage() internal pure returns (ATSStorage storage ds)
    {
        bytes32 position = keccak256("ats.storage");
        assembly { ds.slot := position }
    }


    event SelfDestructing(string reason,uint256 amount);
    event TransferAgentAdded(address newAgent);
    event TransferAgentDisabled(address transferAgent);
    event InvestorAdded(address investor,string investor_type);
    event NewIssuerRegistered(address issuer);
    event NewSecurityRegistered(string symbol,address issuer,uint256 shares);
    event SecurityUpdated(string symbol,string action);
    event TransferFeeChange(address sender,address issuer,string symbol,uint256 fee);
    event TradingEnabled(address issuer,string symbol);
    event TradingStopped(address issuer,string symbol,string reason);
    event ExpiryUpdated(address issuer,string symbol,uint256 expiry);
    event MaximumAccreditedInvestorsUpdated(address issuer,string symbol,uint256 maxInvestors);
    event MaximumSophisticatedInvestorsUpdated(address issuer,string symbol,uint256 maxInvestors);
    event MaximumNonAccreditedInvestorsUpdated(address issuer,string symbol,uint256 maxInvestors);
    event OutstandingSharesUpdated(address issuer,string symbol,uint256 shares);
    event RemainingSharesUpdated(address issuer,string symbol,uint256 shares);
    event SecuirtyIsRestricted(address issuer,string symbol);
    event SecurityIsUnrestricted(address issuer,string symbol);
    event BidPriceUpdated(address transferAgent,address issuer,string symbol,uint256 bid);
    event AskPriceUpdated(address transferAgent,address issuer,string symbol,uint256 ask);
    event MinOfferingAmountUpdated(address transferAgent,address issuer,string symbol,uint256 amount);
    event MaxOfferingAmountUpdated(address transferAgent,address issuer,string symbol,uint256 amount);

    event EthToTokenSwap(address indexed swapper,uint256 indexed ethInput,uint256 indexed tokenOutput);
    event TokenToEthSwap(address indexed swapper,uint256 indexed tokensInput,uint256 indexed ethOutput);
    event LiquidityProvided(address liquidityProvider,uint256 indexed tokensInput,uint256 indexed ethInput,uint256 indexed liquidityMinted);
    event LiquidityRemoved(address liquidityRemover,uint256 indexed tokensOutput,uint256 indexed ethOutput,uint256 indexed liquidityWithdrawn);


    constructor(string memory _tradingSystemName) {
        OWNER = msg.sender;
        TRADING_SYSTEM = _tradingSystemName;
    }

    modifier isOwner() {
        require(msg.sender == OWNER,"not authorized");
        _;
    }

    modifier isTransferAgent() {
        require(atsStorage().transferAgent[msg.sender],"not valid transfer agent");
        _;
    }

    modifier isIssuer() {
        require(atsStorage().issuers[msg.sender],"not a permitted issuer");
        _;
    }

    modifier isIssuerOrTransferAgent() {
        require(atsStorage().transferAgent[msg.sender] || atsStorage().issuers[msg.sender],"not authorized, must be the issuer or a transfer agent");
        _;
    }

    modifier isBrokerDealer() {
        require(atsStorage().broker_dealers[msg.sender],"not a valid broker-dealer");
        _;
    }

    modifier isAccreditedInvestorOrBrokerDealer() {
        require(atsStorage().accredited_investors[msg.sender] || atsStorage().broker_dealers[msg.sender],"unauthorized. not an accredited investor nor a broker-dealer");
        _;
    }

    modifier isTransferAgentOrBrokerDealer() {
        require(atsStorage().transferAgent[msg.sender] || atsStorage().broker_dealers[msg.sender],"not a transfer agent nor a broker-dealer");
        _;
    }

    /*
     * A Transfer Agent is required. The transfer agent can be the issuer or registered broker-dealer, before a 
     * new security is registered.
     */
    function addTransferAgent(address _transferAgent) public isOwner {
        require(atsStorage().transferAgent[_transferAgent] == false,"Already added as a transfer agent");
        atsStorage().transferAgent[_transferAgent] = true;
        emit TransferAgentAdded(_transferAgent);
    }
    function disableTransferAgent(address _transferAgent) public isOwner {
        require(atsStorage().transferAgent[_transferAgent] == true,"not a transfer agent");
        atsStorage().transferAgent[_transferAgent] = false;
        emit TransferAgentDisabled(_transferAgent);
    }
    /*
     * An issuer must be added before a new security can be registered. Only the transfer agent can add an issuer.
     */
    function addIssuer(address _issuer) public isTransferAgent {
        require(atsStorage().issuers[_issuer] == false,"issuer has already been added");
        atsStorage().issuers[_issuer] = true;
        emit InvestorAdded(_issuer, "issuer");
    }
    /*
     */
    function registerSecurity(address _issuer, IOfferingTypeInterface.OfferingType _offeringType,address _token,string memory _symbol,uint256 tokens) public payable isIssuerOrTransferAgent returns (uint256) {
        require(atsStorage().offering[_issuer][_symbol].active == false,"security is already registered");
    
        atsStorage().offering[_issuer][_symbol].token = IERC20(_token);
        atsStorage().offering[_issuer][_symbol].name = IERC20(_token).name();
        atsStorage().offering[_issuer][_symbol].symbol = _symbol;
        atsStorage().offering[_issuer][_symbol].offeringType = _offeringType;
        atsStorage().offering[_issuer][_symbol].started = 0;
        atsStorage().offering[_issuer][_symbol].expiry = 0;
        atsStorage().offering[_issuer][_symbol].maxShares = IERC20(_token).totalSupply();
        atsStorage().offering[_issuer][_symbol].totalSupply = IERC20(_token).totalSupply();
    
        if (atsStorage().issuers[msg.sender]) {
            // issuer is registering the offering
            atsStorage().offering[_issuer][_symbol].issuer = msg.sender;
        } else {
            // transfer agent is registering the offering
            require(atsStorage().issuers[_issuer],"not valid issuer");
            atsStorage().offering[_issuer][_symbol].issuer = _issuer;
        }

        // initializing liquidity
        require(msg.value > 0, "need to send ETH");
        require(msg.value == tokens, "incorrect exchange value");
        require(atsStorage().totalLiquidity == 0, "DEX already initialized");
        require(
            atsStorage().offering[_issuer][_symbol].token.transferFrom(msg.sender, address(this), tokens),
            "transfer failed"
        );
        atsStorage().liquidity[msg.sender] = msg.value;
        return atsStorage().totalLiquidity = address(this).balance;
    }

    /**
     * @notice returns yOutput, or yDelta for xInput (or xDelta)
     */
    function price(
        uint256 xInput,
        uint256 xFee,
        uint256 xReserves,
        uint256 yReserves
    ) public pure returns (uint256 yOutput) {
        // 0.3% trading fee
        xInput = xFee / 1000;
        uint256 numerator = xInput * yReserves;
        uint256 denominator = xReserves + xInput;
        return numerator / denominator;
    }

    /**
     * @notice returns liquidity for a user.
     */
    function getLiquidity(address lp) public view returns (uint256) {
        return atsStorage().liquidity[lp];
    }

    function buy(address _issuer,string memory _symbol) public payable returns (uint256 tokenOutput) {
        return ethToToken(_issuer,_symbol);
    }
    /**
     * @notice sends Ether to DEX in exchange for token
     */
    function ethToToken(address _issuer,string memory _symbol) private returns (uint256 tokenOutput) {
        require(msg.value > 0, "must send ETH");
        tokenOutput = price(
            msg.value,
            atsStorage().offering[_issuer][_symbol].fee,
            (address(this).balance - msg.value),
            atsStorage().offering[_issuer][_symbol].token.balanceOf(address(this))
        );
        require(
            tokenOutput < atsStorage().offering[_issuer][_symbol].token.balanceOf(address(this)),
            "not enough tokens"
        );
        require(atsStorage().offering[_issuer][_symbol].token.transfer(msg.sender, tokenOutput), "transfer failed");
        emit EthToTokenSwap(
            msg.sender,
            msg.value,
            tokenOutput
        );
    }

    function sell(address _issuer,string memory _symbol,uint256 amountTokens) public returns (uint256 ethOutput) {
        return tokenToEth(_issuer,_symbol,amountTokens);        
    }

    /**
     * @notice sends token to DEX in exchange for Ether
     */
    function tokenToEth(address _issuer,string memory _symbol,uint256 tokenInput) private returns (uint256 ethOutput) {
        require(tokenInput > 0, "must send tokens");
        require(
            tokenInput <= atsStorage().offering[_issuer][_symbol].token.balanceOf(msg.sender),
            "invalid token amount"
        );
        ethOutput = price(
            tokenInput,
            atsStorage().offering[_issuer][_symbol].fee,
            atsStorage().offering[_issuer][_symbol].token.balanceOf(address(this)),
            address(this).balance
        );
        require(ethOutput < address(this).balance, "not enough ETH");
        require(
            atsStorage().offering[_issuer][_symbol].token.transferFrom(msg.sender, address(this), tokenInput),
            "token transfer failed"
        );
        (bool success, ) = payable(msg.sender).call{value: ethOutput}("");
        require(success, "ETH transfer failed");
        emit TokenToEthSwap(
            msg.sender,
            ethOutput,
            tokenInput
        );
    }

    /**
     * @notice allows deposits of token and ETH to liquidity pool
     */
    function deposit(address _issuer,string memory _symbol) public payable isAccreditedInvestorOrBrokerDealer returns (uint256 tokensDeposited) {
        // deposit to liquidity permitted for active and non-expired offerings
        require(atsStorage().offering[_issuer][_symbol].active == true,"deposits permitted for active offerings.");
        require(atsStorage().offering[_issuer][_symbol].expiry == 0 || atsStorage().offering[_issuer][_symbol].expiry > block.timestamp,"deposits permitted for unexpired offerings");

        require(msg.value > 0, "need to send liquidity");
        uint256 dy = msg.value;
        uint256 x = atsStorage().offering[_issuer][_symbol].token.balanceOf(address(this)); // token reserves
        uint256 y = address(this).balance - msg.value; // ETH reserves
        tokensDeposited = ((dy * x) / (y + dy));
        uint256 shares = (dy * atsStorage().totalLiquidity) / y;
        atsStorage().offering[_issuer][_symbol].outstanding += shares;
        atsStorage().liquidity[msg.sender] += shares;
        atsStorage().totalLiquidity += shares;
        require(
            atsStorage().offering[_issuer][_symbol].token.transferFrom(msg.sender, address(this), tokensDeposited),
            "token transfer failed"
        );
        emit LiquidityProvided(msg.sender, shares, msg.value, tokensDeposited);
    }

    /**
     * @notice allows withdrawal of tokens and ETH from liquidity pool
     */
    function withdraw(address _issuer,string memory _symbol,uint256 amount)
        public
        isAccreditedInvestorOrBrokerDealer
        returns (uint256 eth_amount, uint256 token_amount)
    {
        // withdrawals permitted for in-active or expired offerings
        require(atsStorage().offering[_issuer][_symbol].active == false || atsStorage().offering[_issuer][_symbol].expiry < block.timestamp,"withdrawals permitted for in-active or expired offerings.");
        require(atsStorage().liquidity[msg.sender] >= amount, "not enough shares");
        // dy = s / T * y
        // dx = s / T * X
        eth_amount = (amount / atsStorage().totalLiquidity) * address(this).balance;
        token_amount =
            (amount / atsStorage().totalLiquidity) *
            atsStorage().offering[_issuer][_symbol].token.balanceOf(address(this));
        atsStorage().offering[_issuer][_symbol].outstanding -= amount;
        atsStorage().liquidity[msg.sender] -= amount;
        atsStorage().totalLiquidity -= amount;
        require(
            atsStorage().offering[_issuer][_symbol].token.transfer(msg.sender, token_amount),
            "token transfer failed"
        );
        (bool success, ) = payable(msg.sender).call{value: eth_amount}("");
        require(success, "ETH transfer failed");
        emit LiquidityRemoved(msg.sender, amount, eth_amount, token_amount);
    }    

    function updateCUSIP(address _issuer,string memory _symbol,string memory _cusip) public isTransferAgent {
        require(atsStorage().offering[_issuer][_symbol].active,"security is not registered");
        atsStorage().offering[_issuer][_symbol].cusip = _cusip;
        emit SecurityUpdated(atsStorage().offering[_issuer][_symbol].symbol, "CUSIP updated");
    }

    function updateISIN(address _issuer,string memory _symbol,string memory _isin) public isTransferAgent {
        require(atsStorage().offering[_issuer][_symbol].active,"security is not registered");
        atsStorage().offering[_issuer][_symbol].isin = _isin;
        emit SecurityUpdated(atsStorage().offering[_issuer][_symbol].symbol, "ISIN updated");
    }

    function setExpiry(address _issuer,string memory _symbol,uint256 _expiry) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].expiry = _expiry;
        emit ExpiryUpdated(_issuer,_symbol,_expiry);
    }

    function startAcceptionTrades(address _issuer,string memory _symbol)  public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].active = true;
        atsStorage().offering[_issuer][_symbol].started = block.timestamp;
        emit TradingEnabled(_issuer,_symbol);        
    }
    function stopAcceptingTrades(address _issuer,string memory _symbol,string memory _reason) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].active = false;
        emit TradingStopped(_issuer,_symbol,_reason);
    }    
    function setMaxAccreditedInvestors(address _issuer,string memory _symbol,uint256 _maxInvestors) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].maxAccredited = _maxInvestors;
        emit MaximumAccreditedInvestorsUpdated(_issuer,_symbol,_maxInvestors);
    }
    function setMaxSophisticatedInvestors(address _issuer,string memory _symbol,uint256 _maxInvestors) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].maxSophisticated = _maxInvestors;
        emit MaximumSophisticatedInvestorsUpdated(_issuer,_symbol,_maxInvestors);
    }
    function setMaxNonAccreditedInvestors(address _issuer,string memory _symbol,uint256 _maxInvestors) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].maxNonAccredited = _maxInvestors;
        emit MaximumNonAccreditedInvestorsUpdated(_issuer,_symbol,_maxInvestors);
    }
    function updateOutstandingShares(address _issuer,string memory _symbol,uint256 _shares) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].outstanding = _shares;
        emit OutstandingSharesUpdated(_issuer,_symbol,_shares);
    }
    function updateRemainingShares(address _issuer,string memory _symbol,uint256 _shares) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].remaining = _shares;
        emit RemainingSharesUpdated(_issuer,_symbol,_shares);
    }
    function setRestrictedSecurity(address _issuer,string memory _symbol) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].restricted = true;
        emit SecuirtyIsRestricted(_issuer,_symbol);
    }
    function setUnRestrictedSecurity(address _issuer,string memory _symbol) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].restricted = false;
        emit SecurityIsUnrestricted(_issuer,_symbol);
    }

    /*
     * Investor types
     */
    function addAcreditedInvestor(address _investor) public isTransferAgentOrBrokerDealer {
        require(atsStorage().accredited_investors[_investor] == false,"accredited investor is already added");
        atsStorage().accredited_investors[_investor] = true;
        emit InvestorAdded(_investor, "accredited-investor");
    }
    function addNonAccreditedInvestor(address _investor) public isTransferAgentOrBrokerDealer {
        require(atsStorage().nonaccredited_investors[_investor] == false,"non-accredited investor is already added");
        atsStorage().nonaccredited_investors[_investor] = true;
        emit InvestorAdded(_investor, "non-accredited investor");
    }
    function addAffiliatedInvestor(address _investor) public isTransferAgentOrBrokerDealer {
        require(atsStorage().affiliated_investors[_investor] == false,"affiliated investor is already added");
        atsStorage().affiliated_investors[_investor] = true;
        emit InvestorAdded(_investor, "affiliated-investor");
    }
    function addBrokerDealer(address _brokerDealer) public isTransferAgent {
        require(atsStorage().broker_dealers[_brokerDealer] == false,"broker-dealer is already added");
        atsStorage().broker_dealers[_brokerDealer] = true;
        emit InvestorAdded(_brokerDealer, "broker-dealer");
    }
    function setFee(address _issuer,string memory _symbol,uint256 _fee) public isTransferAgent {
        require(_fee < 1000,"fee must be greater than 1% (<1000)");
        atsStorage().offering[_issuer][_symbol].fee = _fee;
        emit TransferFeeChange(msg.sender,_issuer,_symbol,_fee);
    }
    function setBid(address _issuer,string memory _symbol,uint256 _bid) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].bid = _bid;
        emit BidPriceUpdated(msg.sender,_issuer,_symbol,_bid);
    }
    function setAsk(address _issuer,string memory _symbol,uint256 _ask) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].ask = _ask;
        emit AskPriceUpdated(msg.sender,_issuer,_symbol,_ask);
    }
    function setMinOfferingAmount(address _issuer,string memory _symbol,uint256 _amount) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].minOffering = _amount;
        emit MinOfferingAmountUpdated(msg.sender,_issuer,_symbol,_amount);
    }
    function setMaxOfferingAmount(address _issuer,string memory _symbol,uint256 _amount) public isTransferAgent {
        atsStorage().offering[_issuer][_symbol].maxOffering = _amount;
        emit MaxOfferingAmountUpdated(msg.sender,_issuer,_symbol,_amount);
    }

    function buyForResale(address payable _issuer,string memory _symbol,uint256 _amount) public payable isBrokerDealer {
        require(atsStorage().offering[_issuer][_symbol].active,"offering does not exists");
        require(msg.value >= atsStorage().offering[_issuer][_symbol].price * _amount,"insufficient funds to purchase");
        //require(atsStorage().offering[_issuer][_symbol].started > 0,"offering has not started");
        //require(atsStorage().offering[_issuer][_symbol].started > block.timestamp,"offering has not started");
        if (atsStorage().offering[_issuer][_symbol].expiry > 0) {
            require(atsStorage().offering[_issuer][_symbol].expiry < block.timestamp,"offering has expired");
        }
        
        require(_amount >= atsStorage().offering[_issuer][_symbol].minOffering,"purchase amount is less than minimum offering");
        require(_amount < atsStorage().offering[_issuer][_symbol].maxOffering,"purchase amount exceeds the maximum offering amount");

        require(_amount <= atsStorage().offering[_issuer][_symbol].maxShares - atsStorage().offering[_issuer][_symbol].outstanding,"not enough available shares to purchase");

        atsStorage().offering[_issuer][_symbol].outstanding += _amount;
        atsStorage().offering[_issuer][_symbol].remaining -= _amount;

        atsStorage().balances[msg.sender][atsStorage().offering[_issuer][_symbol].symbol] += _amount;

        uint256 total = atsStorage().offering[_issuer][_symbol].price * _amount;
        uint256 totalWithFee = total * (atsStorage().offering[_issuer][_symbol].fee / 1000); // 997 / 1000; // 3% fee to the issuer
        uint256 fee = total - totalWithFee;

        payable(atsStorage().offering[_issuer][_symbol].issuer).transfer(totalWithFee);
        payable(address(this)).transfer(fee);
    }

    function getBalance(address _issuer,string memory _symbol) public view returns(uint256) {
        require(atsStorage().offering[_issuer][_symbol].active,"offering does not exists");
        return atsStorage().balances[msg.sender][atsStorage().offering[_issuer][_symbol].symbol];
    }

    function getOfferingType(address _issuer,string memory _symbol) public view returns (IOfferingTypeInterface.OfferingType) {
        return atsStorage().offering[_issuer][_symbol].offeringType;
    }

    function getOffering(address _issuer,string memory _symbol) public view returns (IOfferingInfoInterface.OfferingInfo memory) {
        return atsStorage().offering[_issuer][_symbol];
    }
}