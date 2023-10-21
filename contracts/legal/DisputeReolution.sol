// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

interface IArbitration {
    function hasVoteTimeExpired() external returns (bool);
    function addSideAViewpointComment(string calldata _A) external;
    function addSideBViewpointComment(string calldata _B) external;
}

contract DisputeResolution {

    mapping(address => bool) private partiesA;
    mapping(address => bool) private partiesB;
    mapping(address => bool) public arbitrators;
    
    enum DisputeStatus { NoDispute, PartyADispute, PartyBDispute, Resolved }

    mapping(address => DisputeStatus) private disputeStatus;

    IArbitration arbitrationContract;

    constructor(address arbitrationAddress) {
        arbitrationContract = IArbitration(arbitrationAddress);
        //partyA = msg.sender;
        //partyB = _partyB;
        //arbitrator = _arbitrator;
        //disputeStatus = DisputeStatus.NoDispute;
    }

    modifier onlyParties() {
        require(partiesA[msg.sender] || partiesB[msg.sender], "You are not a party to the contract.");
        _;
    }

    modifier onlyArbitrator() {
        require(arbitrators[msg.sender], "Only the arbitrator can perform this action.");
        _;
    }

    function addParty(address party,bool asPartyA) external onlyArbitrator {
        if (asPartyA) {
            partiesA[party] = true;
        } else {
            partiesB[party] = true;
        }
    }

    function submitDispute(address dispute,string calldata reason) external onlyParties {
        require(disputeStatus[dispute] == DisputeStatus.NoDispute, "There is already a dispute.");
        if (partiesA[msg.sender]) {
            disputeStatus[dispute] = DisputeStatus.PartyADispute;
            arbitrationContract.addSideAViewpointComment(reason);
        } else {
            disputeStatus[dispute] = DisputeStatus.PartyBDispute;
            arbitrationContract.addSideBViewpointComment(reason);
        }
    }

    function resolveDispute(address dispute,bool resolvedInFavorOfPartyA) external onlyArbitrator {
        require(disputeStatus[dispute] != DisputeStatus.NoDispute, "There is no active dispute to resolve.");
        require(arbitrationContract.hasVoteTimeExpired(),"voting has not expired");
        
        if (resolvedInFavorOfPartyA) {
            disputeStatus[dispute] = DisputeStatus.Resolved;
        } else {
            disputeStatus[dispute] = DisputeStatus.NoDispute;
        }
    }

    function resetDispute(address dispute) external onlyArbitrator {
        disputeStatus[dispute] = DisputeStatus.NoDispute;
    }
}
