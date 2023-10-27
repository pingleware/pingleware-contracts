// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/**
 * The ETF or ExchangeTradedFund is like the MortgageBackedSecurity where an Investment Company packages existing security tokens
 * and sells them to buyers on the secondary market.
 */

import "../../libs/SafeMath.sol";
import "../../interfaces/IOffering.sol";

contract ExchangeTradedFund {
    address public issuer;
    uint256 public totalShares;
    uint256 public totalFundsRaised;

    uint256 public issuerFeePercentage = 1; // 1% investment company fee

    IOffering[] public securityTokenBucket;
    uint256 public totalTokens = 0;
    mapping(address => uint256) public shares;

    uint256 public NAV = 0;

    address public owner;
    address public feeRecipient;
    uint256 public feePercentage = 1; // 1% exchange fee

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"not authroized owner");
        _;
    }

    modifier onlyIssuer() {
        _;
    }

    modifier onlyInvestor() {
        _;
    }

    function createTokenOffering(address sponsor,address token,uint256 amount) external onlyIssuer {
        IOffering offering = IOffering(token);

        uint256 maxShares = offering.getMaxOfferingShares(); 
        uint256 outstandingShares = offering.getOutstandingShares();

        uint256 availableShares = SafeMath.safeSub(maxShares,outstandingShares);
        require(availableShares >= amount,"not enough shares to buy");

        uint256 neededToBuy = offering.getPrice() * amount;
        NAV += neededToBuy;

        payable(sponsor).transfer(amount); // sponsor buys and holds the tokens        
        securityTokenBucket.push(IOffering(offering));
        totalTokens++;
        totalShares += amount;
    }

    function setBrokerFeePercentage(uint256 _percentage) external onlyOwner {
        require(_percentage <= 100, "Percentage should be <= 100");
        issuerFeePercentage = _percentage;
    }

    function buy(uint256 amount) external onlyInvestor {
        require(amount > 0, "Amount must be greater than 0");
        totalFundsRaised += amount;
        uint256 sharesToMint = (amount * totalShares) / totalFundsRaised;

        shares[msg.sender] += sharesToMint;
        
        NAV = totalFundsRaised / totalShares;
    }

    function redeem(uint256 sharesToRedeem) external onlyInvestor {
        require(sharesToRedeem > 0, "Shares to redeem must be greater than 0");

        shares[msg.sender] -= sharesToRedeem;

        uint256 redemptionAmount = (sharesToRedeem * totalFundsRaised) / totalShares;        
        totalFundsRaised -= redemptionAmount;
        
        NAV = totalFundsRaised / totalShares;
    }

    // Function to calculate the Net Asset Value (NAV) of the ETF
    function calculateNAV() external returns (uint256) {
        NAV = totalFundsRaised / totalShares;
        return NAV;
    }

    function changeIssuer(address _newIssuer) external onlyOwner {
        issuer = _newIssuer;
    }
}