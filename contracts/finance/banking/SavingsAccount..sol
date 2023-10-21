// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;
import "../../libs/SafeMath.sol";
import "../../libs/DateTime.sol";
import "../../common/Owned.sol";

contract SavingsAccount is Owned {

    uint private INTEREST_RATE = 5; // percentages are represented as whole numbers
    uint private INTEREST_PAYMENT_PERIODS = 4; // 1=annually, 2=bi-annually, 4=quarterly

    uint256 private FIRST_QUARTER = 0; // Jan 1 00:00:00 - Mar 31 23:59:59
    uint256 private SECOND_QUARTER = 0; // Apr 1 00:00:00 - Jun 30 23:59:59
    uint256 private THIRD_QUARTER = 0; // Jul 1 00:00:00 - Sep 30 23:59:59
    uint256 private FORTH_QUARTER = 0; // Oct 1 00:00:00 - Dec 31 23:59:59

    uint256 private FIRST_HALF = 0; // Jan 1 00:00:00 - Jun 30 23:59:59
    uint256 private SECOND_HALF = 0; // Jul 1 00:00:00 - Dec 31 23:59:59

    uint256 private PREVIOUS_YEAR = 0;

    uint256 private year;
    uint256 private month;
    uint256 private day;

    uint256 private total_interest_paid_pending;
    uint256 private contract_balance;

    struct Deposit {
        uint128 balance;
    }

    /**
     * Since solidity does not handle decimals, all numbers are normalized * 100
     */
    struct Transaction {
        uint256 timestamp;
        string  description;
        uint256 debit;
        uint256 credit;
    }

    mapping(address => uint256) public depositors;
    mapping(address => Deposit) private balances;
    mapping(address => Transaction[]) public transactions;

    constructor() {
        total_interest_paid_pending = 0;
        contract_balance = address(this).balance;
    }

    /**
     * ADMINISTRATOR OPERATIONS
     */
    function setCurrentRate() public payable okOwner {
        require(msg.value != 1 || msg.value != 2 || msg.value != 4, "interest payment period is out of range");
        INTEREST_RATE = msg.value;
    }

    function currentRate() public view returns(uint256) {
        return INTEREST_RATE;
    }

    function setInterestPaymentPeriod() public payable okOwner {
        require(msg.value > 0, "Interest rate must be greater than zero");
        INTEREST_PAYMENT_PERIODS = msg.value;
    }

    function interestPaymentPeriod() public view returns(uint256) {
        return INTEREST_PAYMENT_PERIODS;
    }

    function addDepositor(address depositor) public payable okOwner {
        require(depositor != address(0), "Depositor cannot be null address");
        require(depositors[depositor] == 0, "Depositor already exists!");
        depositors[depositor] = 1;
        SafeMath.safeAdd(balances[depositor].balance, msg.value);
        transactions[depositor].push(Transaction(block.timestamp, "OPENING DEPOSIT", 0, msg.value));
    }

    function processBankFee(address depositor, string calldata description) public payable okOwner {
        require(msg.value > 0, "Amount cannot be negative or zero");
        SafeMath.safeSub(balances[depositor].balance, msg.value);
        transactions[depositor].push(Transaction(block.timestamp, description, msg.value, 0));
        SafeMath.safeAdd(contract_balance, msg.value);
    }

    function payInterest(address depositor) public payable okOwner {
        uint count = transactions[depositor].length;
        uint256 lastPayment = 0;

        uint today = block.timestamp;

        (year, month, day) = DateTime.timestampToDate(today);
        FIRST_QUARTER = DateTime.timestampFromDateTime(year,1,1,0,0,0) - DateTime.timestampFromDateTime(year,3,31,23,59,59);
        SECOND_QUARTER = DateTime.timestampFromDateTime(year,4,1,0,0,0) - DateTime.timestampFromDateTime(year,6,30,23,59,59);
        THIRD_QUARTER = DateTime.timestampFromDateTime(year,7,1,0,0,0) - DateTime.timestampFromDateTime(year,9,30,23,59,59);
        FORTH_QUARTER = DateTime.timestampFromDateTime(year,10,1,0,0,0) - DateTime.timestampFromDateTime(year,12,31,23,59,59);

        FIRST_HALF = DateTime.timestampFromDateTime(year,1,1,0,0,0) - DateTime.timestampFromDateTime(year,6,30,23,59,59);
        SECOND_HALF = DateTime.timestampFromDateTime(year,7,1,0,0,0) - DateTime.timestampFromDateTime(year,12,31,23,59,59);

        PREVIOUS_YEAR = DateTime.timestampFromDateTime(year-1,12,31,23,59,59);

        if (count > 0) {
            for (uint i=count; i>count; i--) {
                if (keccak256(abi.encodePacked(transactions[depositor][i].description)) == keccak256(abi.encodePacked("INTEREST PAYMENT")) && lastPayment == 0) {
                    lastPayment = transactions[depositor][i].timestamp;
                }
            }
        }

        if (lastPayment == 0) {
            // If no interest payment transaction, then grab opening date
            lastPayment = transactions[depositor][0].timestamp;
        }

        uint256 interest = SafeMath.safeMul(balances[depositor].balance,SafeMath.safeDiv(SafeMath.safeDiv(INTEREST_RATE,INTEREST_PAYMENT_PERIODS),100));
        if (INTEREST_PAYMENT_PERIODS == 1) {
            if (today > lastPayment && today > PREVIOUS_YEAR) {
                SafeMath.safeAdd(balances[depositor].balance, interest);
                transactions[depositor].push(Transaction(block.timestamp, "INTEREST PAYMENT", 0, interest));
                SafeMath.safeAdd(total_interest_paid_pending, interest);
            }
        } else if (INTEREST_PAYMENT_PERIODS == 2) {
            if (today > lastPayment && today > PREVIOUS_YEAR) {
                SafeMath.safeAdd(balances[depositor].balance, interest);
                transactions[depositor].push(Transaction(block.timestamp, "INTEREST PAYMENT", 0, interest));
                SafeMath.safeAdd(total_interest_paid_pending, interest);
            } else if (today > lastPayment && today > FIRST_HALF) {
                SafeMath.safeAdd(balances[depositor].balance, interest);
                transactions[depositor].push(Transaction(block.timestamp, "INTEREST PAYMENT", 0, interest));
                SafeMath.safeAdd(total_interest_paid_pending, interest);
            }
        } else if (INTEREST_PAYMENT_PERIODS == 4) {
            if (today > lastPayment && today > PREVIOUS_YEAR) {
                SafeMath.safeAdd(balances[depositor].balance, interest);
                transactions[depositor].push(Transaction(block.timestamp, "INTEREST PAYMENT", 0, interest));
                SafeMath.safeAdd(total_interest_paid_pending, interest);
            } else if (today > lastPayment && today > THIRD_QUARTER) {
                SafeMath.safeAdd(balances[depositor].balance, interest);
                transactions[depositor].push(Transaction(block.timestamp, "INTEREST PAYMENT", 0, interest));
                SafeMath.safeAdd(total_interest_paid_pending, interest);
            } else if (today > lastPayment && today > SECOND_QUARTER) {
                SafeMath.safeAdd(balances[depositor].balance, interest);
                transactions[depositor].push(Transaction(block.timestamp, "INTEREST PAYMENT", 0, interest));
                SafeMath.safeAdd(total_interest_paid_pending, interest);
            } else if (today > lastPayment && today > FIRST_QUARTER) {
                SafeMath.safeAdd(balances[depositor].balance, interest);
                transactions[depositor].push(Transaction(block.timestamp, "INTEREST PAYMENT", 0, interest));
                SafeMath.safeAdd(total_interest_paid_pending, interest);
            }
        }
    }

    /**
     * CUSTOMER/DEPOSITOR OPEATIONS
     */
    function makeDeposit() public payable {
        require(msg.value > 0, "Amount cannot be negative or zero");
        require(depositors[msg.sender] != 0, "Depositor does not exists!");
        SafeMath.safeAdd(balances[msg.sender].balance, msg.value);
        transactions[msg.sender].push(Transaction(block.timestamp, "CUSTOMER DEPOSIT", 0, msg.value));
        payable(address(this)).transfer(msg.value);
        SafeMath.safeAdd(contract_balance, msg.value);
    }

    function makeWithdrawal() public payable {
        require(msg.value > 0, "Amount cannot be negative or zero");
        require(depositors[msg.sender] != 0, "Depositor does not exists!");
        require(balances[msg.sender].balance >= msg.value, "Not enough money");
        require(contract_balance > msg.value, "Not enough contract balance for withdrawal");
        SafeMath.safeSub(balances[msg.sender].balance, msg.value);
        transactions[msg.sender].push(Transaction(block.timestamp, "CUSTOMER WITHDRAWAL", msg.value, 0));
        payable(msg.sender).transfer(msg.value);
        SafeMath.safeSub(contract_balance, msg.value);
    }

    function getTransactions() public view returns(Transaction[] memory) {
        require(depositors[msg.sender] != 0, "Depositor does not exists!");
        return transactions[msg.sender];
    }
}