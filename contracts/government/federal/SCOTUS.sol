// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../Case.sol";

contract SCOTUS is Case {
    address public chiefJustice;
    address[] public associateJustices;


    event CaseFiled(string caseId, address petitioner, address respondent, string caseTitle);
    event CaseDecided(string caseId, string decision);

    modifier onlyChiefJustice() {
        require(msg.sender == chiefJustice, "Only the Chief Justice can perform this action.");
        _;
    }

    modifier onlyJustice() {
        require(isJustice(msg.sender), "Only Associate Justices can perform this action.");
        _;
    }

    constructor(address _chiefJustice, address[] memory _associateJustices) {
        chiefJustice = _chiefJustice;
        associateJustices = _associateJustices;
        caseCounter = 0;
    }

    function isJustice(address account) public view returns (bool) {
        for (uint256 i = 0; i < associateJustices.length; i++) {
            if (associateJustices[i] == account) {
                return true;
            }
        }
        return false;
    }

    function fileCase(address respondent, string memory caseTitle) public onlyJustice {
        string memory caseIndex = createCase(msg.sender, respondent, caseTitle);
        emit CaseFiled(caseIndex, msg.sender, respondent, caseTitle);
    }

    function decideCase(string memory caseId, string memory decision) public onlyChiefJustice {
        require(!isCaseResolved(caseId), "This case has already been decided.");
        closeCase(caseId, decision);
        emit CaseDecided(caseId, decision);
    }
}
