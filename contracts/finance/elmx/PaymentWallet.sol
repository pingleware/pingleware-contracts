// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PaymentWallet {
    string public constant name = "PaymentWallet";
    string public constant symbol = "USD";
    uint256 public constant decimals = 2;
    uint256 public constant totalSupply = 1;

    address public contractOwner;
    address private owner;
    uint256 private balance;
    uint256 private expirationDate;
    uint256 private cvvCode;

    event DepositMade(address,address,uint256);
    event Withdrawal(uint256);
    event Transferred(address,uint256);
    event FincenSARS(address,address,uint256,string);
    event AdminTransfer(address,address,uint256,string);

    constructor(address wallet) {
        contractOwner = msg.sender;
        owner = wallet;
        balance = 0;
    }

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "Only the contract owner can perform this action");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier notExpired() {
        require(expirationDate > block.timestamp,"wallet has expired");
        _;
    }

    modifier validCVV(uint256 _cvv) {
        require(_cvv == cvvCode,"CVV not valid");
        _;
    }

    function setExpiration(uint256 _expirationDate) external {
        expirationDate = convertMMYYToTimestamp(_expirationDate);
    }

    function setCVVCode(uint256 _cvvCode) external {
        cvvCode = _cvvCode;
    }

    function deposit(uint256 amount) external {
        if (amount > 10000) {
            emit FincenSARS(msg.sender,owner,amount,"deposit amount exceeds $10,000");
        } else {
            balance += amount;
            emit DepositMade(msg.sender,address(this), amount);
        }
    }

    function withdraw(uint256 amount) external notExpired onlyOwner {
        require(balance >= amount, "Insufficient balance");
        if (amount > 10000) {
            emit FincenSARS(msg.sender,address(0x0),amount,"withdrawal amount exceeds $10,000");
        }
        balance -= amount;
        payable(owner).transfer(amount);
        emit Withdrawal(amount);
    }

    function transfer(address to,uint256 amount,uint256 cvv) external validCVV(cvv) notExpired onlyOwner {
        require(amount <= balance,"insufficient balance");
        if (amount > 10000) {
            emit FincenSARS(msg.sender,to,amount,"transfer amount exceeds $10,000");
        } else {
            balance -= amount;
            PaymentWallet(to).deposit(amount);
            emit Transferred(to, amount);
        }
    }

    function transferFrom(address to, uint256 amount,string calldata reason) external onlyContractOwner {
        require(keccak256(abi.encodePacked(reason)) != keccak256(abi.encodePacked("")),"cannot have an empty reason");
        balance -= amount;
        PaymentWallet(to).deposit(amount);
        emit AdminTransfer(address(this), to, amount,reason);
    }

    function updatedCVV(uint256 _cvvCode) external onlyOwner {
        cvvCode = _cvvCode;
    }

    function getCVV() external view onlyOwner returns (uint256) {
        return cvvCode;
    }

    function updateExpirationDate(uint256 _expirationDate) external onlyOwner {
        expirationDate = convertMMYYToTimestamp(_expirationDate);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function getBalance() external view returns (uint256) {
        return balance;
    }

    function isExpired() external view returns (bool) {
        return block.timestamp > expirationDate;
    }

    function verifyCVV(uint256 _cvv) external view returns (bool) {
        return _cvv == cvvCode;
    }

    function convertMMYYToTimestamp(uint256 mmyy) public view returns (uint256) {
        // Extract the month and year components from MMYY
        uint256 month = mmyy / 100;
        uint256 year = (mmyy % 100) + 2000; // Assuming year format is YY, so we add 2000 to it

        // Check if the provided month is valid (1 to 12)
        require(month >= 1 && month <= 12, "Invalid month");

        // Calculate the Unix timestamp for the first day of the given month
        uint256 timestamp = block.timestamp; // Current timestamp
        timestamp -= (timestamp % 1 days);   // Set time to midnight
        timestamp -= (timestamp % 365 days);  // Go to the beginning of the current year
        timestamp += (year - 1970) * 365 days; // Go to the beginning of the target year
        for (uint256 i = 1; i < month; i++) {
            timestamp += getDaysInMonth(i, year) * 1 days; // Add days for each month
        }

        return timestamp;
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
