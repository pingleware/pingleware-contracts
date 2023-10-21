// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

contract POTUS {
    address public president;
    address public vicePresident;
    string public executiveOrder;

    event ExecutiveOrderIssued(string order);

    modifier onlyPresident() {
        require(msg.sender == president, "Only the President can perform this action.");
        _;
    }

    constructor(address _vicePresident) {
        president = msg.sender;
        vicePresident = _vicePresident;
    }

    function issueExecutiveOrder(string memory order) public onlyPresident {
        executiveOrder = order;
        emit ExecutiveOrderIssued(order);
    }
}
