// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

interface TransactionInterface {
   function addTransaction(address _to, uint256 _shares, uint256 _amount, uint256 _epoch) external;
   function isHoldingPeriodOver(address addr) external view returns (bool);
}
