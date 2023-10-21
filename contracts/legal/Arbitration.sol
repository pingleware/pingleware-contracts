// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Migrated from https://github.com/RychardHunt/blockchain-arbitration/blob/master/blockchainarbitration.sol
 */

/**
 * This Arbitration contract interacts from the DisputeResolution contract
 */

import "../common/Version.sol";
import "../common/Owned.sol";
import "../libs/SafeMath.sol";

contract Arbitration is Version, Owned {
    using SafeMath for uint256;

     uint256 constant TWO_DAYS = 2 days;
     uint256 constant THREE_DAYS = 3 days;

    /**
     * @dev Displays winning solution on the blockchain.
     */
    string public finalSolution;

    /**
    * @dev String A represents the viewpoint and argument of side A;
    *      String B represents the viewpoint and argument of side B;
    */
    string A;
    string B;

    /**
    * @dev Arbitration Fee as a percentage of the total balance of the contract. Base fee is 5%.
    */
    uint256 feePercentage = 5;

    /**
    * @dev solutionToSender stores solutions and addresses of solutions providers.
    *      indexToVoters stores a dynamic array of voter addresses.
    */
    mapping (string => address) private solutionToSender;
    mapping (address => bool) private voters;

    uint256 private voterIndex = 0;

    /*
    * @dev Solutions stores the solutions at the index of the order they are received.
    *      Solutions ID keeps track of how many solutions have been submitted.
    */
    string[10] private solutions;
    uint256 private solutionsId = 0;

    /*
    * @dev votes for solutions of the same index
    *      totalVotes keeps track of total amount of votes. Capped at 101 votes.
    */
    uint256[10] private votes;
    uint256 totalVotes = 0;

    uint256 solutionTimestamp;

    address arbitrator;

    event SolutionTimestampChange(uint256,string);

    /**
    * @dev Constructor initiates String A and String B with the parameters.
    */
    constructor(address arbitratorWallet) {
        arbitrator = arbitratorWallet;
        solutionTimestamp = block.timestamp;
    }

    modifier onlyArbitrator() {
        require(msg.sender == arbitrator,"not authorized arbitrator");
        _;
    }

    /**
    * @dev Modifier for approved solutions senders.
    */
    modifier approveSolutionsSenders() {
        _;
    }

    /**
    * @dev Modifier for approved solutions voters.
    */
    modifier approveSolutionsVoters() {
        require(voters[msg.sender],"not authorized to vote");
        _;
    }

    function addSideAViewpointComment(string calldata _A) external {
         A = _A;
    }

    function addSideBViewpointComment(string calldata _B) external {
         B = _B;
    }

    function getSolutions() external returns (string[] memory) {
        return solutions;
    }

    function getSolution() external returns (string memory) {
        return solutions[getTopSolution()];
    }

    function addVoters(address voter) external onlyArbitrator() {
        voters[voter] = true;
    }

    /**
    * @dev Increase Fees by numbers of percentage points.
    */
    /* function increaseFees(uint256 percent) public onlyOwner {
        require(feePercentage.add(percent) <= 100);
        feePercentage = feePercentage.add(percent);
    } */

    /**
    * @dev Adds a solution to the dispute. Capped at 10 solutions.
    */
    function sendSolution(string memory _solution)
        external
        solutionsTime()
        approveSolutionsSenders()
    {
        require(A.length > 0 && B.length > 0,"parties have not equally responded to the dispute");
        require(solutionsId != 9);
        solutions[solutionsId] = _solution;
        solutionsId = solutionsId.add(1);
        solutionToSender[_solution] = msg.sender;
    }

    /**
    * @dev Increases votes for the index of the solution being voted. Capped at 100 votes.
    */
    function vote(uint256 _solutionsIndex)
        external
        voteTime()
        approveSolutionsVoters()
    {
        require(A.length > 0 && B.length > 0,"parties have not equally responded to the dispute");
        require(totalVotes < 100);
        votes[_solutionsIndex] = votes[_solutionsIndex].add(1);
        totalVotes = totalVotes.add(1);
    }

    function getTopSolution() internal returns (uint256) {
        uint256 solutionIndex = 0;

        for (uint i=0; i<totalVotes; i++) {
            if (votes[i] > votes[solutionIndex]) {
                solutionIndex = i;
            }
        }
        return solutionIndex;
    }

    /**
    * @dev Pays out the arbitration fee to the address of the highest voted solution.
    */
    function payArbitrationFees()
        public
        okOwner
        payable
    {
        uint256 indexMax = 0;
        uint256 maxVotes = votes[indexMax];
        for (uint i = 1; i < 10; i++) {
            if (votes[i] > maxVotes) {
                indexMax = i;
                maxVotes = votes[i];
                // Doesn't deal with ties yet. Edge case.
            }
        }
        finalSolution =  solutions[indexMax];
        payable(solutionToSender[finalSolution]).transfer(address(this).balance);
    }

    /**
    * @dev Restricts solutions sending time to 2 days.
    */
    function solutionsTime() private {
        reuire(SafeMath.safeSub(block.timestamp,solutionTimestamp) < TWO_DAYS,"time expired for sending solutions");
    }

    /**
    * @dev Restricts voting time to 3 days.
    */
    function voteTime() private view {
        reuire(SafeMath.safeSub(block.timestamp,solutionTimestamp) < THREE_DAYS,"time expired for voting on a solution");
    }

    function hasVoteTimeExpired() external view returns (bool) {
        return (SafeMath.safeSub(block.timestamp,solutionTimestamp) < THREE_DAYS);
    }

    function updateSolutionTime(bool currentTimestamp,uint256 newTimestamp,string calldata reason) external onlyArbitrator() {
        require(reason.length > 0,"missing reason for changing timestamp");
        if (currentTimestamp) {
            solutionTimestamp = block.timestamp;
        } else {
            solutionTimestamp = newTimestamp;
        }
        emit SolutionTimestampChange(solutionTimestamp, reason);
    }
}