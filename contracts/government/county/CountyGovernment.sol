// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

contract CountyGovernment {
    string public countyName;
    string public stateName;

    address public countyJudge;
    address[] public commissioners;

    enum ProposalStatus { Proposed, Approved, Rejected }

    struct Proposal {
        uint256 proposalId;
        address proposer;
        string description;
        ProposalStatus status;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCounter;

    event ProposalSubmitted(uint256 proposalId, address proposer, string description);
    event ProposalDecision(uint256 proposalId, ProposalStatus status);

    modifier onlyCountyJudge() {
        require(msg.sender == countyJudge, "Only the County Judge can perform this action.");
        _;
    }

    modifier onlyCommissioner() {
        require(isCommissioner(msg.sender), "Only County Commissioners can perform this action.");
        _;
    }

    constructor(string memory _countyName,string memory _stateName) {
        countyJudge = msg.sender;
        commissioners.push(msg.sender);
        proposalCounter = 0;
        countyName = _countyName;
        stateName = _stateName;
    }

    function getCountyAddress() public view returns (address) {
        return address(this);
    }

    function isCommissioner(address account) public view returns (bool) {
        for (uint256 i = 0; i < commissioners.length; i++) {
            if (commissioners[i] == account) {
                return true;
            }
        }
        return false;
    }

    function addCommissioner(address newCommissioner) public onlyCountyJudge {
        commissioners.push(newCommissioner);
    }

    function submitProposal(string memory description) public onlyCommissioner {
        proposalCounter++;
        proposals[proposalCounter] = Proposal(proposalCounter, msg.sender, description, ProposalStatus.Proposed);
        emit ProposalSubmitted(proposalCounter, msg.sender, description);
    }

    function decideProposal(uint256 proposalId, ProposalStatus status) public onlyCountyJudge {
        require(proposals[proposalId].status == ProposalStatus.Proposed, "This proposal is not pending a decision.");
        proposals[proposalId].status = status;
        emit ProposalDecision(proposalId, status);
    }
}
