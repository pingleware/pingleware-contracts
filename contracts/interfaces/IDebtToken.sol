// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../libs/SafeMath.sol";
import "./IOffering.sol";

interface IDebtToken is IOffering {

    struct BondHolder {
        address holderAddress;
        uint256 investedAmount;
    }

    function purchaseBonds(address investor,uint256 amount,uint256 fee) external;
    function redeemBonds(address investor,uint256 amount,uint256 fee) external;

    event CouponPaymentMade(address,uint256);
    event BondPurchased(address indexed purchaser, uint256 amount);
    event BondRedeemed(address indexed holder, uint256 amount);
}