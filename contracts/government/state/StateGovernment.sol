// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

contract StateGovernment {
    string public stateName;
    address public governor;
    address[] public senateMembers;
    address[] public houseMembers;

    enum BillStatus { Introduced, PassedSenate, PassedHouse, SignedIntoLaw, Vetoed }

    struct Bill {
        uint256 billId;
        address sponsor;
        string title;
        BillStatus status;
    }

    mapping(uint256 => Bill) public bills;
    uint256 public billCounter;

    event BillIntroduced(uint256 billId, address sponsor, string title);
    event BillStatusChange(uint256 billId, BillStatus status);

    modifier onlyGovernor() {
        require(msg.sender == governor, "Only the Governor can perform this action.");
        _;
    }

    modifier onlySenateMember() {
        require(isSenateMember(msg.sender), "Only Senate members can perform this action.");
        _;
    }

    modifier onlyHouseMember() {
        require(isHouseMember(msg.sender), "Only House members can perform this action.");
        _;
    }

    constructor(string memory name) {
        stateName = name;
        governor = msg.sender;
        senateMembers.push(msg.sender);
        houseMembers.push(msg.sender);
        billCounter = 0;
    }

    function isSenateMember(address account) public view returns (bool) {
        for (uint256 i = 0; i < senateMembers.length; i++) {
            if (senateMembers[i] == account) {
                return true;
            }
        }
        return false;
    }

    function isHouseMember(address account) public view returns (bool) {
        for (uint256 i = 0; i < houseMembers.length; i++) {
            if (houseMembers[i] == account) {
                return true;
            }
        }
        return false;
    }

    function addSenateMember(address newMember) public onlyGovernor {
        senateMembers.push(newMember);
    }

    function addHouseMember(address newMember) public onlyGovernor {
        houseMembers.push(newMember);
    }

    function introduceBill(string memory title) public onlySenateMember {
        billCounter++;
        bills[billCounter] = Bill(billCounter, msg.sender, title, BillStatus.Introduced);
        emit BillIntroduced(billCounter, msg.sender, title);
    }

    function passBill(uint256 billId, BillStatus status) public onlyGovernor {
        require(bills[billId].status == BillStatus.Introduced, "This bill cannot be changed.");
        bills[billId].status = status;
        emit BillStatusChange(billId, status);
    }
}
