// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

contract CityCouncil {
    address public mayor;
    address[] public councilMembers;
    
    struct Proposal {
        string description;
        uint256 votes;
        bool passed;
    }
    
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCounter;
    
    event ProposalCreated(uint256 proposalId, string description);
    event ProposalVoted(uint256 proposalId, address voter, bool inSupport);
    
    constructor() {
        mayor = msg.sender;
        councilMembers.push(msg.sender);
        proposalCounter = 0;
    }
    
    modifier onlyMayor() {
        require(msg.sender == mayor, "Only the mayor can perform this action.");
        _;
    }
    
    modifier onlyCouncilMember() {
        require(isCouncilMember(msg.sender), "Only council members can perform this action.");
        _;
    }

    function getCityCouncilAddress() external view returns (address) {
        return address(this);
    }
    
    function isCouncilMember(address account) public view returns (bool) {
        for (uint256 i = 0; i < councilMembers.length; i++) {
            if (councilMembers[i] == account) {
                return true;
            }
        }
        return false;
    }
    
    function addCouncilMember(address newMember) public onlyMayor {
        councilMembers.push(newMember);
    }
    
    function createProposal(string memory description) public onlyCouncilMember {
        proposalCounter++;
        proposals[proposalCounter] = Proposal(description, 0, false);
        emit ProposalCreated(proposalCounter, description);
    }
    
    function voteOnProposal(uint256 proposalId, bool inSupport) public onlyCouncilMember {
        require(proposals[proposalId].votes < councilMembers.length, "This proposal has already been voted on.");
        proposals[proposalId].votes++;
        
        if (proposals[proposalId].votes > councilMembers.length / 2) {
            proposals[proposalId].passed = true;
        }
        
        emit ProposalVoted(proposalId, msg.sender, inSupport);
    }
}
