// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../abstract/AAccessControl.sol";

abstract contract Revenue is AAccessControl {
    enum RevenueType { Fines, Fees, Permits, Donations }
    
    struct RevenueRecord {
        uint256 recordId;
        string payer;
        uint256 amount;
        RevenueType revenueType;
        uint256 paymentDate;
    }
    
    mapping(uint256 => RevenueRecord) public revenueRecords;
    uint256 public recordCounter;

    event RevenueReceived(uint256 recordId, string payer, uint256 amount, RevenueType revenueType, uint256 paymentDate);

    receive() external payable {
        
    }
    
    function receiveRevenue(string memory payer, uint256 amount, RevenueType revenueType) public isOwner {
        recordCounter++;
        revenueRecords[recordCounter] = RevenueRecord(recordCounter, payer, amount, revenueType, block.timestamp);
        emit RevenueReceived(recordCounter, payer, amount, revenueType, block.timestamp);
    }
}