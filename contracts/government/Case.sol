// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

abstract contract Case {
    enum CaseStatus { Pending, InProgress, Closed }

    struct CaseRecord {
        string index;
        address plaintiff;
        address defendant;
        string description;
        uint256 filingDate;
        CaseStatus status;
        string decision;
    }

    uint public caseCounter;

    mapping(string => CaseRecord) public cases;
    mapping(string => address) public assignedJudge;
    mapping(string => address[]) public legalRepresentatives;

    CaseRecord[] _cases;

    event NewCaseCreated(string caseIndex, address plaintiff, address defendant, string description);
    event CaseAssignedJudge(string caseIndex, address judge);
    event LegalRepresentativeAssigned(string caseIndex, address representative);

    constructor() {
        caseCounter = 1;
    }

    function createCase(address _plaintiff, address _defendant, string memory _description) public returns (string memory) {
        require(_plaintiff != _defendant, "Plaintiff and defendant cannot be the same.");
        
        CaseStatus status = CaseStatus.Pending;
        caseCounter++;

        string memory caseIndex = string(abi.encodePacked(uintToString(block.timestamp), uintToString(caseCounter)));
        cases[caseIndex] = CaseRecord(caseIndex,_plaintiff,_defendant, _description, block.timestamp, status, string(""));
        _cases.push(cases[caseIndex]);

        emit NewCaseCreated(caseIndex, _plaintiff, _defendant, _description);
        
        return caseIndex;
    }

    function assignJudge(string calldata _caseIndex, address _judge) public {
        require(msg.sender == cases[_caseIndex].plaintiff, "Only the plaintiff can assign a judge.");
        require(cases[_caseIndex].status == CaseStatus.Pending, "The case is not pending.");

        assignedJudge[_caseIndex] = _judge;
        cases[_caseIndex].status = CaseStatus.InProgress;

        emit CaseAssignedJudge(_caseIndex, _judge);
    }

    function assignLegalRepresentative(string memory _caseIndex, address _representative) public {
        require(msg.sender == cases[_caseIndex].plaintiff || msg.sender == cases[_caseIndex].defendant, "Only the plaintiff or defendant can assign a legal representative.");
        legalRepresentatives[_caseIndex].push(_representative);

        emit LegalRepresentativeAssigned(_caseIndex, _representative);
    }

    function closeCase(string memory _caseIndex,string memory decision) public {
        require(msg.sender == assignedJudge[_caseIndex], "Only the assigned judge can close the case.");
        cases[_caseIndex].status = CaseStatus.Closed;
        cases[_caseIndex].decision = decision;
    }

    function getCaseStatus(string memory _caseIndex) public view returns (CaseStatus) {
        return cases[_caseIndex].status;
    }  

    function isCaseResolved(string memory _caseIndex) public view returns (bool) {
        return (cases[_caseIndex].status == CaseStatus.Closed);
    }

    function getCaseInfo(string memory _caseIndex) public view returns (CaseRecord memory) {
        return cases[_caseIndex];
    }

    function getCaseIndexByDefendant(address defendant) public view returns (string memory) {
        for (uint i=0; i < _cases.length; i++) {
            if (_cases[i].defendant == defendant) {
                return _cases[i].index;
            }
        }
        return "";
    }

    function checkAssignedAttorney(string memory _caseIndex) public view returns (bool) {
        bool assigned = false;
        for (uint i=0; i<legalRepresentatives[_caseIndex].length; i++) {
            if (legalRepresentatives[_caseIndex][i] == msg.sender) {
                assigned = true;
            }
        }
        return assigned;
    }

    function uintToString(uint _uint) internal pure returns (string memory) {
        if (_uint == 0) {
            return "0";
        }

        uint temp = _uint;
        uint digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        while (_uint != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(_uint % 10)));
            _uint /= 10;
        }

        return string(buffer);
    }  
}