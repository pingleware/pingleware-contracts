// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

contract RetailInstallmentSales {
    address public seller; // The address of the seller
    address public buyer;  // The address of the buyer
    uint256 public totalAmount;  // Total amount to be paid by the buyer
    uint256 public annualFee;    // Annual fee in USD
    uint256 public interestRate; // Annual interest rate (up to 18%)

    enum State { Pending, Active, Completed }
    State public state;

    constructor(address _buyer, uint256 _totalAmount, uint256 _annualFee, uint256 _interestRate) {
        seller = msg.sender;
        buyer = _buyer;
        totalAmount = _totalAmount;
        annualFee = _annualFee;
        interestRate = _interestRate;
        state = State.Pending;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only the seller can perform this action");
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only the buyer can perform this action");
        _;
    }

    modifier inState(State _state) {
        require(state == _state, "Invalid state for this operation");
        _;
    }

    function activateContract() external onlySeller inState(State.Pending) {
        state = State.Active;
    }

    function completeContract() external onlySeller inState(State.Active) {
        state = State.Completed;
    }

    function makePayment() external payable onlyBuyer inState(State.Active) {
        // Calculate interest
        uint256 interest = (totalAmount * interestRate) / 100;
        // Calculate the total payment
        uint256 totalPayment = totalAmount + annualFee + interest;
        require(msg.value >= totalPayment, "Insufficient payment");
        if (msg.value > totalPayment) {
            // Refund the excess payment to the buyer
            payable(buyer).transfer(msg.value - totalPayment);
        }
        // Complete the contract
        state = State.Completed;
    }
}
