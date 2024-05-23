// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IPaymentWallet {
    function getCVV() external returns(string memory);
    function transfer(address to,uint256 tokens,string calldata cvv) external returns(bool);
    function transferFrom(address from,address to,uint256 tokens,string calldata cvv) external returns(bool);
    function getBalance(address wallet) external view returns(uint256);
}