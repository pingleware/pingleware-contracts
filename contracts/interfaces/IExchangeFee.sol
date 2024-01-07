// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IExchangeFee {
    event FeeRecipientChanged(address from,address to);
    event FeePercentChanged(uint256 oldAmount,uint256 newAmount);
    event TokenFeeAssessed(address tokenAddress,int256 amount);
    event TokenFeeAdjusted(address tokenAddress,int256 amount);

    function setFeeRecipient(address wallet) external;
    function setFeePercentage(uint256 amount) external;
    function addFee(address tokenAddress, int256 amount) external;
    function subFee(address tokenAddress, int256 amount) external;
    function getTotal(address tokenAddress) external view returns (int256);
    function payFee(address tokenAddress, int256 amount) external payable;
}