// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;
interface IAccount {
    function balanceOf(address addr) external view returns (uint256);
    function isSufficientBalance(address addr, uint256 value) external view returns(bool);
    function setBalance(address addr, uint256 amount) external;
    function getBalance(address addr) external view returns (uint256);
    function add(address addr, uint256 amount) external;
    function sub(address addr, uint256 amount) external;
    function transferBalances(address sender,address receiver) external;
    function transfer(address sender,address receiver, uint256 amount) external;
}
