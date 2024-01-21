// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

// Interface for the Governance Actions
interface IGovernanceActions {
    event ActionExecuted(address sender);
    function executeAction() external;
}

contract DefaultGovernance is IGovernanceActions {
    function executeAction() external {
        emit ActionExecuted(msg.sender);
    }
}

contract GovernanceDAO {
    string public name;
    address public owner;
    uint256 public totalShares;
    uint256 public totalMembers;
    uint256 public totalProposals;
    uint256 public membershipFee;
    uint256 public publicProposalFee;
    mapping(address => uint256) public memberShares;

    // Structure for a proposal
    struct Proposal {
        uint256 id;
        address creator;
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        address actions;
        uint256 deadline;  // New field for proposal deadline
    }

    // Mapping of proposal ID to Proposal
    mapping(uint256 => Proposal) public proposals;

    // List of eligible voters (addresses)
    address[] public voters;

    // Mapping of voter address to their voting power
    mapping(address => uint256) public votingPower;
    // Mapping to track whether a member has voted on a specific proposal
    mapping(uint256 => mapping(address => bool)) private hasVoted;

    // Events
    event MemberAdded(address member);
    event MemberRemoved(address member);
    event ProposalCreated(uint256 proposalId, string description);
    event Voted(uint256 proposalId, address voter, bool support);
    event ProposalExecuted(uint256 proposalId);
    event GovernanceContractAvailable(address governanceContract, uint256 proposalId);
    event MembershipFeeChanged(uint256 oldFee,uint256 newFee,string comments);
    event ProposalDeleted(uint256 indexed proposalId, string reason);
    event PublicProposalFeeChange(uint256 oldFee,uint256 newFee,string comments);


    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
        totalShares = 0;
        totalMembers = 0;
        totalProposals = 0;
        membershipFee = 100000000000000; // onvert to 0.0001
        publicProposalFee = 5000000000000000;
        addMember(owner);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyMember() {
        require(memberShares[msg.sender] > 0, "Only members can perform this action.");
        _;
    }

    modifier onlyCreator(uint256 _proposalId) {
        require(proposals[_proposalId].creator == msg.sender,"not the proposal creator");
        _;
    }

    receive() external payable {}

    function withdraw(address recipient, uint256 amount) public onlyOwner {
        require(recipient != address(0x0),"recipient cannot be a zaero address");
        require(address(this).balance > 0, "insufficient contract balance");
        require(address(this).balance - amount >= 0,"too much withdrawal request");
        payable(recipient).transfer(amount);
    }


    function changeMembershipFee(uint256 fee,string memory comments) public onlyOwner {
        // 100000000000000 WEI = 0.0001 ETHER
        require(fee >= membershipFee,"fee must be at least 100000000000000 Wei or 0.0001 ether. Use https://eth-converter.com/ to convert ETH to WEI.");
        uint256 oldFee = membershipFee;
        membershipFee = fee;
        emit MembershipFeeChanged(oldFee,membershipFee,comments);
    }

    function changePublicProposalFee(uint256 fee,string memory comments) public onlyOwner {
        uint256 oldFee = publicProposalFee;
        publicProposalFee = fee;
        emit PublicProposalFeeChange(oldFee,publicProposalFee,comments);
    }

    function addMember(address member) public onlyOwner {
        memberShares[member] = 1;
        votingPower[member] = 1;
        totalShares += 1;
        totalMembers += 1;
        emit MemberAdded(member);
    }

    function removeMember(address member) public onlyOwner {
        require(member != owner,"owner cannot be removed");
        totalShares -= memberShares[member];
        memberShares[member] = 0;
        emit MemberRemoved(member);
    }

    // Functions for proposal creation, voting, and execution
    function createProposal(string memory _description, uint256 _deadlineInDays) external onlyMember {
        uint256 proposalId = totalProposals;
        uint256 deadline = block.timestamp + (_deadlineInDays * 1 days);
        proposals[proposalId] = Proposal({
            id: proposalId,
            creator: msg.sender,
            description: _description,
            forVotes: 0,
            againstVotes: 0,
            executed: false,
            actions: address(0x0),
            deadline: deadline  // Set the deadline as an absolute timestamp
        });

        totalProposals = totalProposals + 1;

        emit ProposalCreated(proposalId, _description);
    }

    function createPublicPropoal(string memory _description) external payable {
        require(msg.value >= publicProposalFee, "must include 5000000000000000 wei or 0.005 ether (about $12) with the request. Use https://eth-converter.com/ to convert ETH to WEI.");
        uint256 proposalId = totalProposals;
        uint256 deadline = block.timestamp + (30 days);
        proposals[proposalId] = Proposal({
            id: proposalId,
            creator: owner,
            description: _description,
            forVotes: 0,
            againstVotes: 0,
            executed: false,
            actions: address(0x0),
            deadline: deadline  // Set the deadline as an absolute timestamp
        });

        totalProposals = totalProposals + 1;

        emit ProposalCreated(proposalId, _description);
    }

    function vote(uint256 _proposalId, bool _support) external onlyMember {
        require(votingPower[msg.sender] > 0, "Not eligible to vote");
        require(!proposals[_proposalId].executed, "Proposal already executed");
        require(!hasVoted[_proposalId][msg.sender], "Already voted on this proposal");
        require(
            block.timestamp < proposals[_proposalId].deadline,
            "Proposal deadline has passed. No more voting permitted."
        );

        if (_support) {
            proposals[_proposalId].forVotes += votingPower[msg.sender];
        } else {
            proposals[_proposalId].againstVotes += votingPower[msg.sender];
        }

        // Mark the member as voted for this proposal
        hasVoted[_proposalId][msg.sender] = true;

        emit Voted(_proposalId, msg.sender, _support);
    }

    function requestToJoin() external payable {
        require(memberShares[msg.sender] == 0,"you are already a member");
        require(msg.value > (1/membershipFee), "must include monies with the request. Check membershipFee for current value. Use https://eth-converter.com/ to convert ETH to WEI.");

        uint256 proposalId = totalProposals;
        uint256 deadline = block.timestamp + (30 days);
        proposals[proposalId] = Proposal({
            id: proposalId,
            creator: msg.sender,
            description: "REQUEST TO JOIN",
            forVotes: 0,
            againstVotes: 0,
            executed: false,
            actions: address(0x0),
            deadline: deadline
        });

        totalProposals = totalProposals + 1;

        emit ProposalCreated(proposalId, "REQUEST TO JOIN");
    }

    function setGovernanceActionsContract(uint256 _proposalId, address _governanceActionsContract) external onlyCreator(_proposalId) {
        require(proposals[_proposalId].executed == false,"proposal has already been executed");
        require(proposals[_proposalId].actions == address(0x0),"governance action contract is already defined");
        // Set the contract address for governance actions
        proposals[_proposalId].actions = _governanceActionsContract;
    }

    function notifyGovernanceContractAvailable(uint256 _proposalId, address _governanceAddress) external onlyMember {
        emit GovernanceContractAvailable(_governanceAddress, _proposalId);
    }

    function executeProposal(uint256 _proposalId) external onlyCreator(_proposalId) {
        require(
            proposals[_proposalId].forVotes > proposals[_proposalId].againstVotes,
            "Proposal does not have enough support"
        );
        require(!proposals[_proposalId].executed, "Proposal already executed");
        require(
            block.timestamp >= proposals[_proposalId].deadline,
            "Proposal deadline has not passed"
        );
        require(proposals[_proposalId].actions != address(0x0),"governance action contract is not defined");

        // Check if more than 50% of eligible members have voted
        require(
            (proposals[_proposalId].forVotes + proposals[_proposalId].againstVotes) >
            (voters.length / 2),
            "Less than 50% of members have voted"
        );

        // Invoke the governance action from the external contract
        IGovernanceActions governanceActionsContract = IGovernanceActions(proposals[_proposalId].actions);
        governanceActionsContract.executeAction();

        proposals[_proposalId].executed = true;

        emit ProposalExecuted(_proposalId);
    }

    function deleteProposal(uint256 _proposalId, string memory _reason) external onlyOwner {
        require(_proposalId < totalProposals, "Invalid proposal ID");

        // Ensure the proposal has not been executed before deletion
        require(!proposals[_proposalId].executed, "Cannot delete executed proposal");

        // Emit the ProposalDeleted event with the reason
        emit ProposalDeleted(_proposalId, _reason);

        // Delete the proposal by overwriting it with the last proposal in the array
        proposals[_proposalId] = proposals[totalProposals - 1];
        totalProposals = totalProposals - 1;
    }
}
