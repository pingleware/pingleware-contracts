// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../../common/Version.sol";
import "../../common/Frozen.sol";
import "../../interfaces/IExemptLiquidityMarketExchange.sol";

contract MunicipalBond is Version, Frozen {
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

    string public bondName;
    address public issuer;
    address public issuerWallet;
    uint256 public totalPrincipal;
    uint256 public interestRate;
    uint256 public maturityDate;
    bool public isMatured;
    uint256 public depositBalance;
    bool public restricted;
    uint256 public maxBondUnits;
    BondQuote[] public bondQuotes;

    mapping(address => Investor) public investors;
    mapping(address => uint256) public investorQuotes;

    IExemptLiquidityMarketExchange public poolAddress;
    IConsolidatedAuditTrail public catAddress;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event BondMatured();
    event BondTradeAdded(address indexed seller, uint256 bondUnits, uint256 price);
    event BondTradeExecuted(address indexed buyer, address indexed seller, uint256 bondUnits, uint256 price);
    event BondQuoteAdded(address indexed seller, uint256 bondUnits, uint256 price);
    event BondQuoteRemoved(address indexed seller);

    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only the issuer can perform this action");
        _;
    }

    modifier notMatured() {
        require(!isMatured, "The bond has already matured");
        _;
    }

    /**
     * This modifier restricts access to the buy function to accredited investors and broker dealers 
     * when the restricted flag is set to true.
     */ 
    modifier onlyAccreditedAndBrokerDealers() {
        require(
            restricted == true &&
            (isAccreditedInvestor(msg.sender) || isBrokerDealer(msg.sender)),
            "Access restricted to accredited investors and broker dealers"
        );
        _;
    }
    /**
     *  This modifier restricts access to the buy function to registered investors when the restricted flag is set 
     *  to false, or when the flag is set to true and the investor is also a registered investor.
     */
    modifier onlyRegisteredInvestors() {
        require(
            restricted == false || 
            (restricted == true && isRegisteredInvestor(msg.sender)),
            "Access restricted to registered investors"
        );
        _;
    }

    constructor(
        string memory _bondName,
        address _issuer,
        address _issuerWallet,
        uint256 _totalPrincipal,
        uint256 _interestRate,
        uint256 _maturityDate,
        bool _restricted,
        uint256 _maxBondUnits
    ) {
        bondName = _bondName;
        issuer = _issuer;
        issuerWallet = _issuerWallet;
        totalPrincipal = _totalPrincipal;
        interestRate = _interestRate;
        maturityDate = _maturityDate;
        isMatured = false;
        depositBalance = 0;
        restricted = _restricted;
        maxBondUnits = _maxBondUnits;
    }

    function setOfferingPoolContract(address _poolContract) external {
        poolAddress = IExemptLiquidityMarketExchange(_poolContract);
    }

    function setConsolidateAuditTrailContract(address _catContract) external {
        catAddress = IConsolidatedAuditTrail(_catContract);
    }

    function isAccreditedInvestor(address investor) internal view returns (bool) {
        // Implement your own logic to determine if the investor is accredited
        // This could involve checking their income, net worth, or other requirements
        // Return true if the investor is accredited, otherwise return false
        return poolAddress.isAccredited(investor);
    }

    function isBrokerDealer(address investor) internal view returns (bool) {
        // Implement your own logic to determine if the investor is a broker dealer
        // Return true if the investor is a broker dealer, otherwise return false
        return poolAddress.isBrokerDealer(investor);
    }

    function isRegisteredInvestor(address investor) internal view returns (bool) {
        // Implement your own logic to determine if the investor is a registered investor
        // This could involve checking a registration status or qualification requirements
        // Return true if the investor is a registered investor, otherwise return false
        return poolAddress.isWhitelisted(investor);
    }

    function buy() external payable onlyRegisteredInvestors notMatured {
        require(msg.value > 0, "Invalid purchase amount");

        investors[msg.sender].principal += msg.value;

        emit Transfer(address(0), msg.sender, msg.value);

        // Check if the bond is fully funded
        if (getTotalBondUnits() >= maxBondUnits) {
            executeBondTrades();
        }
    }

    function executeBondTrades() internal {
        for (uint256 i = 0; i < bondQuotes.length; i++) {
            if (bondQuotes[i].bondUnits <= maxBondUnits) {
                uint256 totalAmount = bondQuotes[i].bondUnits * bondQuotes[i].price;
                bondQuotes[i].active = false;
                bondQuotes[i].bondUnits = 0;
                bondQuotes[i].price = 0;
                payable(bondQuotes[i].seller).transfer(totalAmount);

                emit Transfer(address(this), bondQuotes[i].seller, bondQuotes[i].bondUnits);
                emit BondTradeExecuted(msg.sender, bondQuotes[i].seller, bondQuotes[i].bondUnits, bondQuotes[i].price);

                maxBondUnits -= bondQuotes[i].bondUnits;
            }
        }
    }

    function addBondTrade(uint256 bondUnits, uint256 price) external onlyRegisteredInvestors notMatured {
        require(bondUnits > 0, "Invalid bond units");
        require(price > 0, "Invalid price");

        bondQuotes.push(BondQuote(msg.sender, bondUnits, price, true));

        emit BondQuoteAdded(msg.sender, bondUnits, price);
    }

    function removeBondQuote() external onlyRegisteredInvestors notMatured {
        require(investorQuotes[msg.sender] > 0, "No bond quote available");

        uint256 bondUnits = investorQuotes[msg.sender];
        investorQuotes[msg.sender] = 0;

        emit BondQuoteRemoved(msg.sender);

        // Refund the bond units to the investor
        payable(msg.sender).transfer(bondUnits);
    }

    // Rest of the contract functions...

    function getTotalBondUnits() public view returns (uint256) {
        uint256 totalUnits = 0;
        for (uint256 i = 0; i < bondQuotes.length; i++) {
            if (bondQuotes[i].active) {
                totalUnits += bondQuotes[i].bondUnits;
            }
        }
        return totalUnits;
    }

    function quoteBondUnits(uint256 bondUnits) external onlyRegisteredInvestors {
        require(bondUnits > 0, "Invalid bond units");

        investorQuotes[msg.sender] = bondUnits;
    }

    function getBondQuote(address seller) public view returns (uint256 bondUnits, uint256 price, bool active) {
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
