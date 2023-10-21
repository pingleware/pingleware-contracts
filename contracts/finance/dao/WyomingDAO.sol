// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

contract WyomingDAO {
    string public name;
    address public owner;
    uint256 public totalShares;
    mapping(address => uint256) public memberShares;

    event MemberAdded(address member, uint256 shares);
    event MemberRemoved(address member);
    event ProposalCreated(uint256 proposalId, string description);
    event VoteCasted(address member, uint256 proposalId, bool vote);

    struct Proposal {
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }

    Proposal[] public proposals;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyMember() {
        require(memberShares[msg.sender] > 0, "Only members can perform this action.");
        _;
    }

    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
        totalShares = 0;
    }

    function addMember(address member, uint256 shares) public onlyOwner {
        memberShares[member] += shares;
        totalShares += shares;
        emit MemberAdded(member, shares);
    }

    function removeMember(address member) public onlyOwner {
        totalShares -= memberShares[member];
        memberShares[member] = 0;
        emit MemberRemoved(member);
    }

    function createProposal(string memory description) public onlyMember {
        proposals.push(Proposal(description, 0, 0, false));
        emit ProposalCreated(proposals.length - 1, description);
    }

    function vote(uint256 proposalId, bool inFavor) public onlyMember {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "This proposal has already been executed.");

        if (inFavor) {
            proposal.votesFor += memberShares[msg.sender];
        } else {
            proposal.votesAgainst += memberShares[msg.sender];
        }

        emit VoteCasted(msg.sender, proposalId, inFavor);
    }

    function executeProposal(uint256 proposalId) public onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "This proposal has already been executed.");

        if (proposal.votesFor > proposal.votesAgainst) {
            // Execute the proposal here.
            proposal.executed = true;
        }
    }
}
