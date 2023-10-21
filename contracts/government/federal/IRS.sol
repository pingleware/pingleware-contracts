// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../../abstract/AAccessControl.sol";

contract IRS is AAccessControl {
address public taxCollector;
    uint256 public totalTaxCollected;

    mapping(address => uint256) public taxpayerBalances;

    event TaxCollected(address from, uint256 amount);

    receive() external payable {

    }

    modifier onlyTaxCollector() {
        require(msg.sender == taxCollector, "Only the tax collector can perform this action.");
        _;
    }

    function collectTax() public payable {
        uint256 amount = msg.value;
        taxpayerBalances[msg.sender] += amount;
        totalTaxCollected += amount;
        emit TaxCollected(msg.sender, amount);
    }

    function getTaxBalance() public view returns (uint256) {
        return taxpayerBalances[msg.sender];
    }

    function withdrawTaxRefund() public {
        require(taxpayerBalances[msg.sender] > 0, "no refund available");
        uint256 refundAmount = taxpayerBalances[msg.sender];
        taxpayerBalances[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);
    }
}