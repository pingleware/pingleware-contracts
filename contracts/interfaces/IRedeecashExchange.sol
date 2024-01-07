// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IRedeecashExchange {
    event SecurityListed(address issuer,address tokenAddress);

    function addSecurityOffering(address issuer,address tokenAddress) external;
    function buy(address tokenAddress,uint256 quantity,uint256 price) external payable;
    function sell(address tokenAddress,uint256 quantity,uint256 price) external payable;
}