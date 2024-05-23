// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IExchangeFee {
    event FeeRecipientChanged(address formerRecipient,address wallet);
    event FeePercentChanged(uint256 formerAmount,uint256 amount);

    function setFeeRecipient(address wallet) external;
    function setFeePercentage(uint256 amount) external;
}