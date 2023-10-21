// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IPaymentWallet {
    function transfer(address to,uint256 amount,uint256 cvv) external;
    function transferFrom(address to, uint256 amount,string calldata reason) external;
    function getCVV() external view returns (uint256);
    function getBalance() external view returns (uint256);
}