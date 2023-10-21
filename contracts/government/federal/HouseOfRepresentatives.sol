// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;


contract HouseOfRepresentatives {
    address public speaker;
    address[] public members;

    enum BillStatus { Introduced, Passed, Failed }

    struct Bill {
        uint256 billId;
        address sponsor;
        string title;
        BillStatus status;
    }

    mapping(uint256 => Bill) private bills;
    uint256 private billCounter;

    event BillIntroduced(uint256 billId, address sponsor, string title);
    event BillStatusChange(uint256 billId, BillStatus status);

    modifier onlySpeaker() {
        require(msg.sender == speaker, "Only the Speaker of the House can perform this action.");
        _;
    }

    modifier onlyMember() {
        require(isMember(msg.sender), "Only House members can perform this action.");
        _;
    }

    modifier onlyRepresentative() {
        require(isMember(msg.sender), "Only Representatives can perform this action.");
        _;
    }

    constructor() {
        speaker = msg.sender;
        members.push(msg.sender);
        billCounter = 0;
    }

    function isMember(address account) public view returns (bool) {
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == account) {
                return true;
            }
        }
        return false;
    }

    function addMember(address newMember) public onlySpeaker {
        members.push(newMember);
    }

    function addRepresentative(address newRepresentative) public onlySpeaker {
        members.push(newRepresentative);
    }

    function introduceBill(string memory title) public virtual onlyMember {
        billCounter++;
        bills[billCounter] = Bill(billCounter, msg.sender, title, BillStatus.Introduced);
        emit BillIntroduced(billCounter, msg.sender, title);
    }

    function passBill(uint256 billId, BillStatus status) public onlySpeaker {
        require(bills[billId].status == BillStatus.Introduced, "This bill cannot be changed.");
        bills[billId].status = status;
        emit BillStatusChange(billId, status);
    }
}
