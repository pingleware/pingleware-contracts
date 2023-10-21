// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../interfaces/IExchangeFee.sol";

abstract contract AExchangeFee is IExchangeFee {
    address public feeRecipient;
    uint256 public FeePercentage = 1; // Fee percentage

    function setFeeRecipient(address wallet) external {
        address formerRecipient = feeRecipient;
        require(wallet != address(0x0),"cannit be null address");
        feeRecipient = wallet;
        emit FeeRecipientChanged(formerRecipient, wallet);
    }

    function setFeePercentage(uint256 amount) external {
        uint256 formerAmount = FeePercentage;
        require(amount > 0 && amount <= 100, "must be greater than zero or less than or equal to 100");
        FeePercentage = amount;
        emit FeePercentChanged(formerAmount, amount);
    }
}