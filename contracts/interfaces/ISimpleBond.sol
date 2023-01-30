// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

abstract contract ISimpleBond {
  event MintedBond(address buyer, uint256 bondsAmount);
  event RedeemedCoupons(address indexed caller, uint256[] bonds);
  event ClaimedPar(address indexed caller, uint256 amountClaimed);
  event Transferred(address indexed from, address indexed to, uint256[] bonds);

  function changeLoopLimit(uint256 _loopLimit) public virtual;
  function mintBond(address buyer, uint256 bondsAmount) public virtual;
  function redeemCoupons(uint256[] calldata _bonds) public virtual;
  function transfer(address receiver, uint256[] calldata bonds) public virtual;
  function donate() public virtual payable;

  //PRIVATE
  function getMoney(uint256 amount, address receiver) public virtual;

  //GETTERS
  function getBondOwner(uint256 bond) public virtual view returns (address);
  function getRemainingCoupons(uint256 bond) public virtual view returns (int256);
  function getLastTimeRedeemed(uint256 bond) public virtual view returns (uint256);
  function getSimpleInterest() public virtual view returns (uint256);
  function getCouponsRedeemed(uint256 bond) public virtual view returns (uint256);
  function getTokenAddress() public virtual view returns (address);
  function getTimesToRedeem() public virtual view returns (uint256);
  function getTerm() public virtual view returns (uint256);
  function getMaturity(uint256 bond) public virtual view returns (uint256);
  function getCouponRate() public virtual view returns (uint256);
  function getParValue() public virtual view returns (uint256);
  function getCap() public virtual view returns (uint256);
  function getBalance(address who) public virtual view returns (uint256);
  function getParDecimals() public virtual view returns (uint256);
  function getTokenToRedeem() public virtual view returns (address);
  function getName() public virtual view returns (string memory);
  function getTotalDebt() public virtual view returns (uint256);
  function getTotalBonds() public virtual view returns (uint256);
  function getNonce() public virtual view returns (uint256);
  function getCouponThreshold() public virtual view returns (uint256);
}