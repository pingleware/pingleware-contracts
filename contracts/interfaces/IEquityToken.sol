// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../libs/SafeMath.sol";
import "./IOffering.sol";

interface IEquityToken is IOffering {
    struct Shareholder {
        address wallet;
        uint256 investedAmount;
        uint256 shares;
    }

    event ShareholderAdded(address);
    event ShareholderInvestmentAdded(address,uint256);
    event ShareholderSharesAllocated(address,uint256);
}