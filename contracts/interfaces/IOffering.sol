// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IOffering {
    event TransferStatusChanged(bool,string);
    event TradingStatusChanged(bool,string);

    function validate(address from,address to,uint tokens) external view returns (bool);
    function transfer(address from,address to, uint tokens)  external returns (bool);
    function transferFrom(address from, address to, uint tokens)  external returns (bool);
    function getBalanceFrom(address wallet) external view returns (uint256); 
    function getTradingStatus() external view returns (bool);
    function changeTradingStatus(bool,string calldata) external;

    function buy(address wallet,uint256 tokens,uint256 Fee) external;

    //function getMaxOfferingShares() external view returns (uint256);
    //function getOutstandingShares() external view returns (uint256);
    //function getSymbol() external view returns (string memory);
    //function getName() external view returns (string memory);
    //function getPrice() external view returns (uint256);
    //function getTotalSupply() external view returns (uint256);
    //function getIssuer() external view returns (address);

    function getIssuer() external view returns (address);
    function getOutstandingShares() external view returns (uint256);
    function getTotalSupply() external view returns (uint256);
    function getOfferingType() external view returns (string memory);
}