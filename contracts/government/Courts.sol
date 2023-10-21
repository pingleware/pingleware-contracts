// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../abstract/AAccessControl.sol";
import "./Case.sol";

abstract contract Courts is AAccessControl, Case {

    event CaseFiled(string caseId, address plaintiff, address defendant, string description, uint256 filingDate);
    event CaseResolved(string caseId);

    function fileCase(address plaintiff, address defendant, string memory description) public isOwner {
        string memory caseIndex = createCase(plaintiff, defendant, description);
        emit CaseFiled(caseIndex, plaintiff, defendant, description, block.timestamp);
    }
    
    function resolveCase(string memory caseId,string memory decision) public isOwner {
        require(isCaseResolved(caseId) == false, "Case is already resolved.");
        closeCase(caseId,decision);
        emit CaseResolved(caseId);
    }
}