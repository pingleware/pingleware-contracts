// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

contract RegD506CEquity  {
    address public owner;
    address public issuer; // The issuer of the security tokens
    string public offeringName;
    string public offeringDescription;
    uint256 public totalSupply;
    uint256 public accreditedInvestorCount;
    uint256 public minimumInvestmentAmount;
    uint256 public maximumInvestmentAmount;
    bool public offeringClosed;

    mapping(address => bool) public accreditedInvestors;
    mapping(address => bool) public badActors;
    mapping(address => string) public jurisdictions;

    event InvestorVerified(address indexed investor);
    event BadActorIdentified(address indexed badActor);
    event TokensPurchased(address indexed investor, uint256 amount);

    constructor(
        string memory _offeringName,
        string memory _offeringDescription,
        uint256 _totalSupply,
        uint256 _minimumInvestmentAmount,
        uint256 _maximumInvestmentAmount
    ) {
        issuer = msg.sender;
        offeringName = _offeringName;
        offeringDescription = _offeringDescription;
        totalSupply = _totalSupply;
        minimumInvestmentAmount = _minimumInvestmentAmount;
        maximumInvestmentAmount = _maximumInvestmentAmount;
        offeringClosed = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only the issuer can perform this action");
        _;
    }

    modifier offeringOpen() {
        require(!offeringClosed, "The offering is closed");
        _;
    }

    modifier accreditedInvestor() {
        require(accreditedInvestors[msg.sender], "Only accredited investors can participate");
        _;
    }

    modifier notBadActor() {
        require(!badActors[msg.sender], "Investor identified as a bad actor");
        _;
    }

    function verifyInvestor(address _investor) public onlyIssuer {
        accreditedInvestors[_investor] = true;
        accreditedInvestorCount++;
        emit InvestorVerified(_investor);
    }

    function identifyBadActor(address _badActor) public onlyIssuer {
        badActors[_badActor] = true;
        emit BadActorIdentified(_badActor);
    }

    function closeOffering() public onlyIssuer offeringOpen {
        offeringClosed = true;
    }

    function purchaseTokens(uint256 _amount) public payable offeringOpen accreditedInvestor notBadActor {
        require(msg.value >= _amount, "Insufficient funds");
        require(_amount >= minimumInvestmentAmount, "Investment amount too low");
        require(_amount <= maximumInvestmentAmount, "Investment amount too high");
        // Implement token transfer logic here
        emit TokensPurchased(msg.sender, _amount);
    }

    mapping(address => uint256) public tokenBalances;

    event TokensTransferred(address indexed from, address indexed to, uint256 amount);

    modifier transferableTokens(uint256 _amount) {
        require(tokenBalances[msg.sender] >= _amount, "Insufficient tokens");
        _;
    }

    function transferTokens(address _to, uint256 _amount) public transferableTokens(_amount) {
        tokenBalances[msg.sender] -= _amount;
        tokenBalances[_to] += _amount;
        emit TokensTransferred(msg.sender, _to, _amount);
    }

    // Implement a compliance check function for Rule 506(c).
    // This function should check whether the investor is accredited and not a bad actor.
    function checkRule506CCompliance(address _investor) public view returns (bool) {
        if (accreditedInvestors[_investor] && !badActors[_investor]) {
            return true;
        }
        return false;
    }

    // Implement functions to issue and manage tokens.
    // You can use popular token standards like ERC20 or ERC721, depending on your requirements.

    // Implement state registration check.
    mapping(string => bool) public registeredStates;  // Mapping of registered states

    function registerState(string memory state) public onlyOwner {
        registeredStates[state] = true;
    }

    function unregisterState(string memory state) public onlyOwner {
        registeredStates[state] = false;
    }

    function isInvestorEligible(address investor) public view returns (bool) {
        return registeredStates[jurisdictions[investor]];
    }

    // Implement additional functions for the STO.

    // Implement regulatory compliance checks for Rule 506(c).
    function updatedInvestorJurisdiction(address wallet,string memory state) public onlyIssuer {
        jurisdictions[wallet] = state;
    } 
    // Implement additional functions for the STO, such as transferring tokens, compliance checks, and more.

}