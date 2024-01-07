// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../libs/SafeMath.sol";
import "./IOffering.sol";
import "./IConsolidatedAuditTrail.sol";

interface IEquityToken is IOffering {
    struct Shareholder {
        address wallet;
        uint256 investedAmount;
        uint256 shares;
        uint256 timestamp;
    }

    event ShareholderAdded(address);
    event ShareholderInvestmentAdded(address investor,uint256 tokens,uint256 amount,uint256 fee);
    event ShareholderInvestmentDepleted(address investor,uint256 tokens,uint256 amount,uint256 fee);
    event ShareholderSharesAllocated(address,uint256);

    function purchaseShares(address wallet,uint256 tokens,uint256 Fee) external;
    function sellShares(address wallet,uint256 certificateNo,uint256 tokens) external;
}