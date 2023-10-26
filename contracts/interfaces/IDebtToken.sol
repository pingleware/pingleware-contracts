// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../libs/SafeMath.sol";
import "./IOffering.sol";

interface IDebtToken is IOffering {

    struct BondHolder {
        address holderAddress;
        uint256 investedAmount;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event CouponPaymentMade(address,uint256);
    event BondRedeemed(address,uint256);

}