// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../../libs/SafeMath.sol";
import "../../interfaces/IBestBooks.sol";
import "../../abstract/AAccessControl.sol";
import "../../abstract/AExchangeFee.sol";

contract ExchangeFee is AAccessControl, AExchangeFee {
    mapping (address => int256) private fees;

    IBestBooks bestbooksContract;


    constructor(address bestbooksAddress) {
        bestbooksContract = IBestBooks(bestbooksAddress);
    }

    function addFee(address tokenAddress, int256 amount) external nonReentrant isOwner {
        if (amount == 0) {
            amount = SafeMath.safeMul(fees[tokenAddress], int256(FeePercentage));
        }
        fees[tokenAddress] = SafeMath.safeAdd(fees[tokenAddress], amount);
        bestbooksContract.addEntry(block.timestamp, "CASH", "FEES", "Exchange Fee", amount, amount);
        emit TokenFeeAssessed(tokenAddress,amount);
    }

    function subFee(address tokenAddress, int256 amount) external nonReentrant isOwner {
        require(fees[tokenAddress] > 0,"NSF");
        if (amount == 0) {
            amount *= int256(FeePercentage);
        }
        fees[tokenAddress] -= amount;
        bestbooksContract.addEntry(block.timestamp, "CASH", "FEES", "Exchange Fee ADJUSTED", amount, amount);
        emit TokenFeeAdjusted(tokenAddress,amount);
    }

    function getTotal(address tokenAddress) external view isOwner returns (int256) {
        return fees[tokenAddress];
    }
}