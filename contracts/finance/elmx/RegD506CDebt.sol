// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

contract RegD506CDebt {
    address public issuer;  // The issuer of the bond
    string public bondName;  // Name of the bond
    uint256 public totalSupply;  // Total supply of bonds
    uint256 public bondPrice;  // Price per bond
    uint256 public maturityDate;  // Bond maturity date
    mapping(address => uint256) public bondBalances;  // Bond balances for each investor
    mapping(address => bool) public accreditedInvestors;  // Accredited investor status

    event BondPurchased(address indexed purchaser, uint256 amount);
    event BondRedeemed(address indexed holder, uint256 amount);

    constructor(
        string memory _bondName,
        uint256 _totalSupply,
        uint256 _bondPrice,
        uint256 _maturityDate
    ) {
        issuer = msg.sender;
        bondName = _bondName;
        totalSupply = _totalSupply;
        bondPrice = _bondPrice;
        maturityDate = _maturityDate;
    }

    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only the issuer can perform this action");
        _;
    }

    modifier onlyAccreditedInvestor() {
        require(accreditedInvestors[msg.sender], "Only accredited investors are allowed");
        _;
    }

    function purchaseBonds(uint256 amount) external payable {
        require(msg.value == amount * bondPrice, "Incorrect payment amount");
        require(amount > 0 && amount <= totalSupply, "Invalid bond amount");
        require(block.timestamp < maturityDate, "Bond maturity date reached");

        bondBalances[msg.sender] += amount;
        totalSupply -= amount;
        emit BondPurchased(msg.sender, amount);
    }

    function redeemBonds(uint256 amount) external onlyAccreditedInvestor {
        require(bondBalances[msg.sender] >= amount, "Insufficient bond balance");

        bondBalances[msg.sender] -= amount;
        totalSupply += amount;
        payable(msg.sender).transfer(amount * bondPrice);
        emit BondRedeemed(msg.sender, amount);
    }

    function verifyAccreditedInvestor(address investor) external onlyIssuer {
        accreditedInvestors[investor] = true;
    }

    // Additional functions for managing the bond contract, compliance checks, and reporting.

}