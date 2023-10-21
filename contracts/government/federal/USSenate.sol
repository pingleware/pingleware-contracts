// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

contract USSenate {
    address public majorityLeader;
    address[] public senators;

    enum BillStatus { Introduced, Passed, Failed }
    enum ConfirmationStatus { Pending, Confirmed, Rejected }

    struct Bill {
        uint256 billId;
        address sponsor;
        string title;
        BillStatus status;
    }

    struct Nomination {
        uint256 nominationId;
        address nominee;
        string position;
        ConfirmationStatus status;
    }

    mapping(uint256 => Bill) private bills;
    mapping(uint256 => Nomination) private nominations;
    uint256 private billCounter;
    uint256 private nominationCounter;

    event BillIntroduced(uint256 billId, address sponsor, string title);
    event BillStatusChange(uint256 billId, BillStatus status);
    event NominationSubmitted(uint256 nominationId, address nominee, string position);
    event NominationStatusChange(uint256 nominationId, ConfirmationStatus status);

    modifier onlyMajorityLeader() {
        require(msg.sender == majorityLeader, "Only the Majority Leader can perform this action.");
        _;
    }

    modifier onlySenator() {
        require(isSenator(msg.sender), "Only Senators can perform this action.");
        _;
    }

    constructor() {
        majorityLeader = msg.sender;
        senators.push(msg.sender);
        billCounter = 0;
        nominationCounter = 0;
    }

    function isSenator(address account) public view returns (bool) {
        for (uint256 i = 0; i < senators.length; i++) {
            if (senators[i] == account) {
                return true;
            }
        }
        return false;
    }

    function addSenator(address newSenator) public onlyMajorityLeader {
        senators.push(newSenator);
    }

    function introduceBill(string memory title) public virtual onlySenator {
        billCounter++;
        bills[billCounter] = Bill(billCounter, msg.sender, title, BillStatus.Introduced);
        emit BillIntroduced(billCounter, msg.sender, title);
    }

    function passBill(uint256 billId, BillStatus status) public onlyMajorityLeader {
        require(bills[billId].status == BillStatus.Introduced, "This bill cannot be changed.");
        bills[billId].status = status;
        emit BillStatusChange(billId, status);
    }

    function submitNomination(string memory position, address nominee) public onlySenator {
        nominationCounter++;
        nominations[nominationCounter] = Nomination(nominationCounter, nominee, position, ConfirmationStatus.Pending);
        emit NominationSubmitted(nominationCounter, nominee, position);
    }

    function confirmNomination(uint256 nominationId, ConfirmationStatus status) public onlyMajorityLeader {
        require(nominations[nominationId].status == ConfirmationStatus.Pending, "This nomination cannot be changed.");
        nominations[nominationId].status = status;
        emit NominationStatusChange(nominationId, status);
    }
}
