// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../../interfaces/IHouseOfRepresentatives.sol";
import "../../interfaces/IUSSenate.sol";

contract Congress {
    enum BillStatus { Introduced, Passed, Failed }

    struct Bill {
        uint256 billId;
        address sponsor;
        string title;
        BillStatus status;
    }

    mapping(uint256 => Bill) private bills;
    uint256 private billCounter;

    IHouseOfRepresentatives public house;
    IUSSenate public senate;


    constructor(address houseAddress,address senateAddress) {
        house = IHouseOfRepresentatives(houseAddress);
        senate = IUSSenate(senateAddress);
    }

    function introduceBill(string memory title) external {
        billCounter++;
        bills[billCounter] = Bill(billCounter, msg.sender, title, BillStatus.Introduced);

        if (house.isMember(msg.sender)) {
            house.introduceBill(title);
        } else if (senate.isSenator(msg.sender)) {
            senate.introduceBill(title);
        }
    }

     // Get the full certificate details
    function getCertificate(string memory electionYear) public view returns (string memory, string memory, string memory, string memory) {
        return (house.getPresidentElect(electionYear), electionYear, house.getHouseCertificate(electionYear), senate.getSenateCertificate(electionYear));
    }
}