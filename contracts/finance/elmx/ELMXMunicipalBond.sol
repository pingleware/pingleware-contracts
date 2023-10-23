// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../../interfaces/IExemptLiquidityMarketExchange.sol";

contract ELMXMunicipalBond {
    struct Investor {
        uint256 principal;
        uint256 interestEarned;
        bool redeemed;
    }

    struct BondTrade {
        address seller;
        uint256 bondUnits;
        uint256 price; 
    }

    struct BondQuote {
        address seller;
        uint256 bondUnits;
        uint256 price;
        bool active;
    }

    address public owner;

    string public bondName;
    address public bondIssuer;
    uint256 public bondTotalPrincipal;
    uint256 public bondInterestRate;
    uint256 public bondMaturityDate;
    bool public isMatured;
    uint256 public depositBalance;
    bool public bondRestricted;
    uint256 public maxBondUnits;
    BondQuote[] public bondQuotes;

    mapping(address => Investor) public investors;
    mapping(address => uint256) public investorQuotes;

    IExemptLiquidityMarketExchange public exchangeContract;

    address public feeRecipient;
    uint256 public FeePercentage = 1; // Fee percentage

    event FeeRecipientUpdated(address indexed newRecipient);
    event FeePercentageUpdated(uint256 newPercentage);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event BondMatured();
    event BondTradeAdded(address indexed seller, uint256 bondUnits, uint256 price);
    event BondTradeExecuted(address indexed buyer, address indexed seller, uint256 bondUnits, uint256 price);
    event BondQuoteAdded(address indexed seller, uint256 bondUnits, uint256 price);
    event BondQuoteRemoved(address indexed seller);

    modifier isOwner() {
        require(msg.sender == owner,"not authorized");
        _;
    }

    modifier notMatured() {
        isMatured = block.timestamp > bondMaturityDate;
        emit BondMatured();
        require(!isMatured, "The bond has already matured");
        _;
    }


    constructor(
        string memory name,
        address issuer,
        uint256 totalPrincipal,
        uint256 interestRate,
        uint256 maturityDate,
        bool restricted,
        uint256 maxUnits,
        address exchangeAddress
    ) {
        owner = msg.sender;

        bondName = name;
        bondIssuer = issuer;
        bondTotalPrincipal = totalPrincipal;
        bondInterestRate = interestRate;
        bondMaturityDate = maturityDate;
        isMatured = false;
        depositBalance = 0;
        bondRestricted = restricted;
        maxBondUnits = maxUnits;

        exchangeContract = IExemptLiquidityMarketExchange(exchangeAddress);
    }

    function setFeeRecipient(address wallet) external isOwner {
        feeRecipient = address(wallet);
        emit FeeRecipientUpdated(wallet);       
    }

    function setFee(uint256 fee) external isOwner {
        require(fee <= 100, "Fee percentage must be 100 or less");
        FeePercentage = fee; // 1=1% deposit fee
        emit FeePercentageUpdated(fee);
    }

    /**
     *  This modifier restricts access to the buy function to registered investors when the restricted flag is set 
     *  to false, or when the flag is set to true and the investor is also a registered investor.
     */
    function onlyRegisteredInvestors(address wallet) internal view returns (bool) {
        if (bondRestricted == false || (bondRestricted == true && isRegisteredInvestor(wallet))) {
            return true;
        }
        return false;
    }

    /**
     * This modifier restricts access to the buy function to accredited investors and broker dealers 
     * when the restricted flag is set to true.
     */ 
    function onlyAccreditedAndBrokerDealers(address wallet) internal view returns (bool) {
        if (bondRestricted == true && (isAccreditedInvestor(wallet) || isBrokerDealer(wallet))) {
            return true;
        }
        return false;
    }

    function isAccreditedInvestor(address investor) internal view returns (bool) {
        // Implement your own logic to determine if the investor is accredited
        // This could involve checking their income, net worth, or other requirements
        // Return true if the investor is accredited, otherwise return false
        return exchangeContract.isAccredited(investor);
    }

    function isBrokerDealer(address investor) internal view returns (bool) {
        // Implement your own logic to determine if the investor is a broker dealer
        // Return true if the investor is a broker dealer, otherwise return false
        return exchangeContract.isBrokerDealer(investor);
    }

    function isRegisteredInvestor(address investor) internal view returns (bool) {
        // Implement your own logic to determine if the investor is a registered investor
        // This could involve checking a registration status or qualification requirements
        // Return true if the investor is a registered investor, otherwise return false
        return exchangeContract.isWhitelisted(investor);
    }

    function buy(address wallet,uint256 amount) external isOwner notMatured {

        require(amount > 0, "Invalid purchase amount");

        investors[wallet].principal += amount;

        emit Transfer(address(this), wallet, amount);

        // Calculate the total fee amount
        uint256 Fee = (amount * FeePercentage) / 100;
        // Transfer the fee amount to the fee recipient
        if (Fee > 0) {
            exchangeContract.addEntry(block.timestamp,"Cash","RCEX Fee",string(abi.encodePacked("RCEX Fee for ",bondName," bond token")),int256(Fee),int256(Fee));
        }

        // Check if the bond is fully funded
        if (getTotalBondUnits() >= maxBondUnits) {
            executeBondTrades(wallet);
        }
    }

    function executeBondTrades(address wallet) internal {
        for (uint256 i = 0; i < bondQuotes.length; i++) {
            if (bondQuotes[i].bondUnits <= maxBondUnits) {
                uint256 totalAmount = bondQuotes[i].bondUnits * bondQuotes[i].price;
                bondQuotes[i].active = false;
                bondQuotes[i].bondUnits = 0;
                bondQuotes[i].price = 0;
                //payable(bondQuotes[i].seller).transfer(totalAmount);
                if (investors[bondQuotes[i].seller].principal >= totalAmount) {
                    investors[bondQuotes[i].seller].principal -= totalAmount;

                    emit Transfer(address(this), bondQuotes[i].seller, bondQuotes[i].bondUnits);
                    emit BondTradeAdded(bondQuotes[i].seller, bondQuotes[i].bondUnits, bondQuotes[i].price);
                    emit BondTradeExecuted(wallet, bondQuotes[i].seller, bondQuotes[i].bondUnits, bondQuotes[i].price);

                    // save CAT
                    string memory eventData = string(abi.encodePacked("SELLER: ", bondQuotes[i].seller, ", BUYER: ", wallet, ", UNITS: ", exchangeContract.uintToString(bondQuotes[i].bondUnits), ", PRICE: ", exchangeContract.uintToString(bondQuotes[i].price)));
                    exchangeContract.addAuditEntry(bondName,exchangeContract.timestampToString(),"Municipal Bond Trade Executed",eventData);

                    maxBondUnits -= bondQuotes[i].bondUnits;
                }
            }
        }
    }

    function addBondTrade(address wallet,uint256 bondUnits, uint256 price) external isOwner notMatured {
        require(onlyAccreditedAndBrokerDealers(wallet),"not accredited nor broker-dealer");
        require(bondUnits > 0, "Invalid bond units");
        require(price > 0, "Invalid price");

        bondQuotes.push(BondQuote(wallet, bondUnits, price, true));

        emit BondQuoteAdded(wallet, bondUnits, price);

        // save CAT
        string memory eventData = string(abi.encodePacked("BROKER-DEALEER: ", wallet,", UNITS: ", exchangeContract.uintToString(bondUnits), ", PRICE: ", exchangeContract.uintToString(price)));
        exchangeContract.addAuditEntry(bondName,exchangeContract.timestampToString(),"Municipal Bond Trade Added",eventData);
    }

    function removeBondQuote(address wallet) external isOwner notMatured {
        require(onlyAccreditedAndBrokerDealers(wallet),"not accredited nor broker-dealer");
        require(investorQuotes[wallet] > 0, "No bond quote available");

        uint256 bondUnits = investorQuotes[wallet];
        investorQuotes[wallet] = 0;

        emit BondQuoteRemoved(wallet);

        // save CAT
        string memory eventData = string(abi.encodePacked("BROKER-DEALEER: ", wallet,", UNITS: ", exchangeContract.uintToString(bondUnits)));
        exchangeContract.addAuditEntry(bondName,exchangeContract.timestampToString(),"Municipal Bond Trade Removed",eventData);
    }

    function getTotalBondUnits() public view isOwner returns (uint256) {
        uint256 totalUnits = 0;
        for (uint256 i = 0; i < bondQuotes.length; i++) {
            if (bondQuotes[i].active) {
                totalUnits += bondQuotes[i].bondUnits;
            }
        }
        return totalUnits;
    }

    function quoteBondUnits(address wallet,uint256 bondUnits) external isOwner {
        require(onlyRegisteredInvestors(wallet),"not registered");
        require(bondUnits > 0, "Invalid bond units");

        investorQuotes[wallet] = bondUnits;
    }

    function getBondQuote(address seller) public view isOwner returns (uint256 bondUnits, uint256 price, bool active) {
        for (uint256 i = 0; i < bondQuotes.length; i++) {
            if (bondQuotes[i].seller == seller) {
                return (
                    bondQuotes[i].bondUnits,
                    bondQuotes[i].price,
                    bondQuotes[i].active
                );
            }
        }
        return (0, 0, false);
    }
}