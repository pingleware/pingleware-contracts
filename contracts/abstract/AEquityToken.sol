// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../interfaces/IAccessControl.sol";
import "../interfaces/IEquityToken.sol";

abstract contract AEquityToken is IAccessControl, IEquityToken {
    uint256 constant public SIXMONTHS = 180 days;
    uint256 constant public YEAR = 365 days;

    bool public TRADING_ACTIVE      =   false;
    bool public TRANSFERS_ACTIVE    =   false;

    uint256 public OUTSTANDING_SHARES = 0;
    uint256 public MAX_OFFERING_SHARES = 0; // no maximum imposed on Rule 3(a)(11)

    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public price;

    string public offeringType = "EQUITY";

    event TransferStatusChange(bool,string);
    event TradingStatusChange(bool,string);

    function getName() external view returns (string memory) {
        return name;
    }

    function getSymbol() external view returns (string memory) {
        return symbol;
    }

    function getTotalSupply() external view returns (uint256) {
        return totalSupply;
    }

    function getOfferingType() external view returns (string memory) {
        return offeringType;
    }

    function getTradingStatus() external view returns (bool) {
        return TRADING_ACTIVE;
    }

    function changeTradingStatus(bool status,string calldata reason) external {
        TRADING_ACTIVE = status;
        emit TradingStatusChange(status,reason);
    }
    function changeTransferStatus(bool status,string calldata reason) external {
        TRANSFERS_ACTIVE = status;
        emit TransferStatusChange(status,reason);
    }

    function getOutstandingShares() external view returns (uint256) {
        return OUTSTANDING_SHARES;
    }

    /**
     * Needed to calculate the Exchange Market Index
     * Total Exchange Market Value = sum of each offering market value [getMarketValue()]
     * Exchange Market Index = sum of the product of the offering price and offering merket weigth
     */
    function getMarketValue() external view returns (uint256) {
        return SafeMath.safeMul(price, OUTSTANDING_SHARES);
    }

    function getMarketWeight(uint256 totalExchangeMarketValue) external view returns (uint256) {
        // normalized to account for decimals
        return SafeMath.safeMul(SafeMath.safeDiv(SafeMath.safeMul(price, OUTSTANDING_SHARES),totalExchangeMarketValue),100);
    }
}