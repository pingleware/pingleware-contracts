// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../interfaces/IAccessControl.sol";
import "../interfaces/IDebtToken.sol";

abstract contract ADebtToken is IAccessControl, IDebtToken {
    uint256 constant public SIXMONTHS = 180 days;
    uint256 constant public YEAR = 365 days;
    bool public TRANSFERS_ACTIVE    =   false;
    bool public TRADING_ACTIVE = false;

    uint256 public OUTSTANDING_SHARES = 0;
    uint256 public MAX_OFFERING_SHARES = 0;

    string public name; // Name of the corporate bond
    address public issuer; // Address of the bond issuer
    uint256 public bondPrincipal; // Principal amount of the bond
    uint256 public bondCouponRate; // Annual coupon rate (in basis points)
    uint256 public bondMaturityDate; // Unix timestamp of the bond maturity date
    uint256 public bondRating; // Bond rating of the issuer (on a scale of 1 to 10)

    BondHolder[] public bondHolders;

    string public offeringType = "DEBT";

    event TransferStatusChange(bool,string);
    event TradingStatusChange(bool,string);

    
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
    function changeTradingStatus(bool status,string calldata reason) external {
        TRADING_ACTIVE = status;
        emit TradingStatusChange(status,reason);
    }
    function changeTransferStatus(bool status,string calldata reason) external {
        TRANSFERS_ACTIVE = status;
        emit TransferStatusChange(status,reason);
    }
}