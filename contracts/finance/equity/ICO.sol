// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;
/**
* @title ICO CONTRACT
* @dev ERC-20 Token Standard Compliant
* @author Fares A. Akel C. f.antonio.akel@gmail.com
*/
import "../../libs/SafeMath.sol";
import "../../interfaces/IERC20.sol";

contract ICO {
    using SafeMath for uint256;
    //This ico have 5 states
    enum State {
        preico,
        week1,
        week2,
        week3,
        week4,
        week5,
        week6,
        week7,
        Successful
    }

    
    //public variables
    State public state = State.preico; //Set initial stage
    uint256 public startTime = block.timestamp; //block-time when it was deployed
    uint256 public rate;
    uint256 public totalRaised; //eth in wei
    uint256 public totalDistributed; //tokens
    uint256 public totalContributors;
    uint256 public ICOdeadline;
    uint256 public completedAt;
    IERC20 public tokenReward;
    address public creator;
    string public campaignUrl;
    string public version = '1';

    //events for log
    event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
    event LogBeneficiaryPaid(address _beneficiaryAddress);
    event LogFundingSuccessful(uint _totalRaised);
    event LogFunderInitialized(
        address _creator,
        string _url,
        uint256 _ICOdeadline);
    event LogContributorsPayout(address _addr, uint _amount);

    modifier notFinished() {
        require(state != State.Successful);
        _;
    }
    /**
    * @notice ICO constructor
    * @param _campaignUrl is the ICO _url
    * @param _addressOfTokenUsedAsReward is the token totalDistributed
    */
    constructor (string memory _campaignUrl,address _addressOfTokenUsedAsReward)
    {
        require(_addressOfTokenUsedAsReward!=address(0), "no zero address");

        creator = msg.sender;
        campaignUrl = _campaignUrl;
        tokenReward = IERC20(_addressOfTokenUsedAsReward);
        rate = 3214;
        ICOdeadline = startTime.add(63 days); //9 weeks

        emit LogFunderInitialized(
            creator,
            campaignUrl,
            ICOdeadline);
    }

    /**
    * @notice contribution handler
    */
    function contribute() public notFinished payable {

        uint256 tokenBought = 0;

        totalRaised = totalRaised.add(msg.value);
        totalContributors = totalContributors.add(1);

        tokenBought = msg.value.mul(rate);

        //Rate of exchange depends on stage
        if (state == State.preico){

            tokenBought = tokenBought.mul(14);
            tokenBought = tokenBought.mul(10); //14/10 = 1.4 = 140%
        
        } else if (state == State.week1){

            tokenBought = tokenBought.mul(13);
            tokenBought = tokenBought.mul(10); //13/10 = 1.3 = 130%

        } else if (state == State.week2){

            tokenBought = tokenBought.mul(125);
            tokenBought = tokenBought.mul(100); //125/100 = 1.25 = 125%

        } else if (state == State.week3){

            tokenBought = tokenBought.mul(12);
            tokenBought = tokenBought.mul(10); //12/10 = 1.2 = 120%

        } else if (state == State.week4){

            tokenBought = tokenBought.mul(115);
            tokenBought = tokenBought.mul(100); //115/100 = 1.15 = 115%

        } else if (state == State.week5){

            tokenBought = tokenBought.mul(11);
            tokenBought = tokenBought.mul(10); //11/10 = 1.10 = 110%

        } else if (state == State.week6){

            tokenBought = tokenBought.mul(105);
            tokenBought = tokenBought.mul(100); //105/100 = 1.05 = 105%

        }

        totalDistributed = totalDistributed.add(tokenBought);
        
        tokenReward.transfer(msg.sender, tokenBought);

        emit LogFundingReceived(msg.sender, msg.value, totalRaised);
        emit LogContributorsPayout(msg.sender, tokenBought);
        
        checkIfFundingCompleteOrExpired();
    }

    /**
    * @notice check status
    */
    function checkIfFundingCompleteOrExpired() public {

        if(state == State.preico && block.timestamp > startTime.add(14 days)){

            state = State.week1;

        } else if(state == State.week1 && block.timestamp > startTime.add(21 days)){

            state = State.week2;
            
        } else if(state == State.week2 && block.timestamp > startTime.add(28 days)){

            state = State.week3;
            
        } else if(state == State.week3 && block.timestamp > startTime.add(35 days)){

            state = State.week4;
            
        } else if(state == State.week4 && block.timestamp > startTime.add(42 days)){

            state = State.week5;
            
        } else if(state == State.week5 && block.timestamp > startTime.add(49 days)){

            state = State.week6;
            
        } else if(state == State.week6 && block.timestamp > startTime.add(56 days)){

            state = State.week7;
            
        } else if(block.timestamp > ICOdeadline && state!=State.Successful ) { //if we reach ico deadline and its not Successful yet

            state = State.Successful; //ico becomes Successful
            completedAt = block.timestamp; //ICO is complete

            emit LogFundingSuccessful(totalRaised); //we log the finish
            finished(); //and execute closure
        }
    }

    /**
    * @notice closure handler
    */
    function finished() public { //When finished eth are transfered to creator

        require(state == State.Successful);
        uint256 remanent = tokenReward.balanceOf(address(this));

        require(payable(creator).send(address(this).balance));
        tokenReward.transfer(creator,remanent);

        emit LogBeneficiaryPaid(creator);
        emit LogContributorsPayout(creator, remanent);

    }

    /*
    * @dev Direct payments handle
    */

    receive() external payable {
        contribute();
    }
}