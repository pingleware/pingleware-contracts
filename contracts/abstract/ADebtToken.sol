// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../interfaces/IDebtToken.sol";
import "./AToken.sol";

abstract contract ADebtToken is AToken, IDebtToken {

    uint256 public bondPrincipal; // Principal amount of the bond
    uint256 public bondCouponRate; // Annual coupon rate (in basis points)
    uint256 public bondMaturityDate; // Unix timestamp of the bond maturity date
    uint256 public bondRating; // Bond rating of the issuer (on a scale of 1 to 10)

    BondHolder[] public bondHolders;


    function purchaseBonds(address investor,uint256 amount,uint256 fee) public {
        require(amount > 0 && amount <= MAX_OFFERING_SHARES && amount <= (MAX_OFFERING_SHARES - OUTSTANDING_SHARES), "Invalid bond amount");
        require(block.timestamp < bondMaturityDate, "Bond maturity date reached");

        OUTSTANDING_SHARES += amount;
        paymentWalletContract.transferFrom(address(this), investor, amount, "N/A");

        if (fee > 0) {
            exchangeContract.addEntry(block.timestamp,"Cash","RCEX Fee",string(abi.encodePacked("RCEX Fee for ",name," token")),int256(fee),int256(fee));
        }

        emit BondPurchased(investor, amount);
    }

    function redeemBonds(address investor,uint256 amount,uint256 fee) public {
        require(amount <= OUTSTANDING_SHARES, "Insufficient bond balance");

        OUTSTANDING_SHARES -= amount;
        paymentWalletContract.transferFrom(investor, address(this), amount, "N/A");

        if (fee > 0) {
            exchangeContract.addEntry(block.timestamp,"Cash","RCEX Fee",string(abi.encodePacked("RCEX Fee for ",name," token")),int256(fee),int256(fee));
        }

        emit BondRedeemed(investor, amount);
    }

    
    function getMarketValue() public returns (uint256) {
        // Convert percentage values to decimals
        bondCouponRate = bondCouponRate * 1e16; // Convert to 18 decimal places
        uint256 yield = (bondPrincipal * bondCouponRate) / 100;

        // Calculate the present value of the bond's future cash flows
        uint256 marketValue = 0;
        uint256 maturityYears = calculateMaturityYears();
        for (uint256 year = 1; year <= maturityYears; year++) {
            uint256 couponPayment = (bondPrincipal * bondCouponRate) / 1e18; // Convert back to 18 decimal places
            uint256 discountFactor = (1e18 + yield) ** year;
            marketValue += couponPayment / discountFactor;
        }

        // Add the present value of the face value at maturity
        marketValue += (bondPrincipal / ((1e18 + yield) ** maturityYears));

        return marketValue;
    }

    function getMarketWeight(uint256 totalExchangeMarketValue) external returns (uint256) {
        // normalized to account for decimals
        return SafeMath.safeMul(SafeMath.safeDiv(getMarketValue(),totalExchangeMarketValue),100);
    }

    function calculateMaturityYears() internal view returns (uint256) {
        require(bondMaturityDate >= block.timestamp, "Maturity date must be in the future");

        // Calculate the number of seconds until maturity
        uint256 secondsToMaturity = bondMaturityDate - block.timestamp;

        // Calculate the number of years (assuming 365 days per year)
        uint256 maturityYears = secondsToMaturity / 365 days;

        return maturityYears;
    }
    function getPrice() external view returns (uint256) {
        return bondPrincipal;
    }
}