// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../abstract/AAccessControl.sol";

abstract contract Tax is AAccessControl {
    enum TaxType { IncomeTax, SalesTax, PropertyTax, CorporateTax }
    
    struct TaxRecord {
        uint256 recordId;
        address taxpayer;
        uint256 amount;
        TaxType taxType;
        uint256 paymentDate;
    }
    
    mapping(uint256 => TaxRecord) public taxRecords;
    uint256 public recordCounter;

    event TaxPaid(uint256 recordId, address taxpayer, uint256 amount, TaxType taxType, uint256 paymentDate);

    receive() external payable {

    }
    
    function payTax(TaxType taxType) public payable {
        recordCounter++;
        taxRecords[recordCounter] = TaxRecord(recordCounter, msg.sender, msg.value, taxType, block.timestamp);
        emit TaxPaid(recordCounter, msg.sender, msg.value, taxType, block.timestamp);
    }
    
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    function withdrawBalance(address recipient) public isOwner {
        payable(recipient).transfer(address(this).balance);
    }
}