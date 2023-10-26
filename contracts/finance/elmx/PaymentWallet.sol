// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../../interfaces/IPaymentWallet.sol";

contract PaymentWallet is IPaymentWallet{
    string public constant name = "PaymentWallet";
    string public constant symbol = "USD";
    uint256 public constant decimals = 2;
    uint256 public constant totalSupply = 1;

    address public contractOwner;

    mapping(address => Wallet) private wallets;


    constructor() {
        contractOwner = msg.sender;
    }

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "Only the contract owner can perform this action");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == wallets[msg.sender].owner, "Only the owner can perform this action");
        _;
    }

    modifier notExpired(address wallet) {
        require(wallets[wallet].expirationDate > block.timestamp,"wallet has expired");
        _;
    }

    modifier validCVV(address wallet,uint256 _cvv) {
        require(_cvv == wallets[wallet].cvvCode,"CVV not valid");
        _;
    }

    function addWallet(address wallet,uint256 balance,uint256 expirationDate,uint256 cvcCode) external onlyContractOwner {
        wallets[wallet] = Wallet(wallet,balance,expirationDate,cvcCode);
    }

    function setExpiration(address wallet,uint256 _expirationDate) external onlyContractOwner {
        wallets[wallet].expirationDate = _expirationDate;
    }

    function setCVVCode(address wallet,uint256 _cvvCode) external onlyContractOwner {
        wallets[wallet].cvvCode = _cvvCode;
    }

    function deposit(address wallet,uint256 amount) notExpired(wallet) external {
        if (amount > 10000) {
            emit FincenSARS(msg.sender,wallet,amount,"deposit amount exceeds $10,000");
        } else {
            wallets[wallet].balance += amount;
            emit DepositMade(msg.sender,wallet,amount);
        }
    }

    function withdraw(uint256 amount) external payable notExpired(msg.sender) onlyOwner {
        require(wallets[msg.sender].balance >= amount, "Insufficient balance");
        if (amount > 10000) {
            emit FincenSARS(msg.sender,msg.sender,amount,"withdrawal amount exceeds $10,000");
        }
        wallets[msg.sender].balance -= amount;
        //payable(msg.sender).transfer(amount);
        emit Withdrawal(amount);
    }

    function transfer(address to,uint256 amount,uint256 cvv) external validCVV(msg.sender,cvv) notExpired(msg.sender) notExpired(to) onlyOwner {
        require(amount <= wallets[msg.sender].balance,"insufficient balance");
        if (amount > 10000) {
            emit FincenSARS(msg.sender,to,amount,"transfer amount exceeds $10,000");
        } else {
            wallets[msg.sender].balance -= amount;
            wallets[to].balance += amount;
            emit Transferred(to,amount);
        }
    }

    function transferFrom(address from,address to, uint256 amount,string calldata reason) external notExpired(from) notExpired(to) onlyContractOwner {
        require(keccak256(abi.encodePacked(reason)) != keccak256(abi.encodePacked("")),"cannot have an empty reason");
        wallets[from].balance -= amount;
        wallets[to].balance += amount;
        emit AdminTransfer(from, to, amount,reason);
    }

    function updatedCVV(address wallet,uint256 _cvvCode) external onlyContractOwner {
        wallets[wallet].cvvCode = _cvvCode;
    }

    function getCVV() external view onlyOwner returns (uint256) {
        return  wallets[msg.sender].cvvCode;
    }

    function updateExpirationDate(address wallet,uint256 _expirationDate) external onlyContractOwner {
        wallets[wallet].expirationDate = _expirationDate;
    }

    function getOwner(address wallet) external view returns (address) {
        return wallets[wallet].owner;
    }

    function getBalance(address wallet) external view returns (uint256) {
        return wallets[wallet].balance;
    }

    function isExpired(address wallet) external view returns (bool) {
        return block.timestamp > wallets[wallet].expirationDate;
    }

    function verifyCVV(address wallet,uint256 _cvv) external view returns (bool) {
        return _cvv == wallets[wallet].cvvCode;
    }

    function getExpirationDate(address wallet) external view returns (uint256) {
        return wallets[wallet].expirationDate;
    }

    function getBlockTimestamp() external view returns (uint256) {
        return block.timestamp;
    }


    function getDaysInMonth(uint256 month, uint256 year) internal pure returns (uint256) {
        if (month == 2) {
            if (isLeapYear(year)) {
                return 29;
            } else {
                return 28;
            }
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        } else {
            return 31;
        }
    }

    function isLeapYear(uint256 year) internal pure returns (bool) {
        return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
    }    
}
