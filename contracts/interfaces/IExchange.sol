// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "./IConsolidatedAuditTrail.sol";
interface IExchange is IConsolidatedAuditTrail {
    function getInvestorJurisdiction(address wallet) external view returns(string memory);
    function getInvestorStatus(address wallet) external view returns(bool);
    function usdToWei(uint256 usdAmount) external returns(uint256);
    function addEntry(uint256 timestamp,string calldata debit,string calldata credit,string calldata description,int256 debitAmount,int256 creditAmoount) external;
    function isAccredited(address wallet) external view returns(bool);
    function isAffiliate(address wallet) external view returns(bool);
    function isTransferAgent(address wallet) external view returns(bool);
    function isBrokerDealer(address wallet) external view returns(bool);
    function isWhitelisted(address wallet) external view returns(bool);
    function transferShares(address from,address to,address contractAddress,int256 amount) external;
    function timestampToString() external returns(string memory);
    function addAuditEntry(string calldata symbol,string calldata timestamp,REPORTABLE_EVENT mode,string calldata eventData) external;
    function uintToString(uint tokens) external returns(string memory);
    function getShares(address wallet,address tokenAddress) external view returns(int256);
    function addInvestor(string calldata symbol,address wallet) external;
    function addShares(address wallet,address tokenAddress,int256 shares) external;
    function formatEventDataForOrderRouting(string calldata blockhashTimestamp,string calldata issuer,string calldata wallet,string calldata timestamp,string calldata extra,string calldata extra2,string calldata tokens) external returns(string memory);
    function quote(string calldata symbol) external view returns (uint256 volume,uint256 bid,uint256 ask,uint256 high,uint256 low);
}