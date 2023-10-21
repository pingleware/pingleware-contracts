// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * This library is using Diamond Storage to hold state variables. Additionally, library functions cannot have payable methods, in essence we have gas-free state variables?
 */
import "../interfaces/ITransaction.sol";


contract Account {
    ITransaction private transaction;

    event AccountBalanceTransfer(address sender,address receiver,uint256 amount);
    event AccountTransfer(address sender,address receiver,uint256 amount);

    modifier isValidAddress(address addr) {
        require (addr != address(0), "zero address not permitted");
        _;
    }

    /**
     * @dev Diamond storage for adding state variables in libraries
     * https://dev.to/mudgen/solidity-libraries-can-t-have-state-variables-oh-yes-they-can-3ke9
     */
    struct AccountStorage {
        mapping (address => uint256) _balance;
    }

    constructor(address transaction_contract) {
        transaction = ITransaction(transaction_contract);
    }

    function accountStorage() internal pure returns (AccountStorage storage ds)
    {
        bytes32 position = keccak256("account.storage");
        assembly { ds.slot := position }
    }

    function balanceOf(address addr) 
        external
        view
        isValidAddress(addr)
        returns (uint256)
    {
        // @dev To reference the mapping using diamon storage
        // https://medium.com/@mudgen/new-storage-layout-for-proxy-contracts-and-diamonds-98d01d0eadb
        return accountStorage()._balance[addr];
    }

    function isSufficientBalance(address addr, uint256 value) 
        external
        view
        isValidAddress(addr)
        returns (bool)
    {
        return (accountStorage()._balance[addr] > value);
    }

    function setBalance(address addr, uint256 amount)
        external
        isValidAddress(addr)
    {
        transaction.addTransaction(addr,0,amount,block.timestamp);
        accountStorage()._balance[addr] = amount;
    }

    function getBalance(address addr) 
        external
        view
        isValidAddress(addr)
        returns (uint256)
    {
        return accountStorage()._balance[addr];
    }

    function add(address addr, uint256 amount)
        external
        isValidAddress(addr)
    {
        transaction.addTransaction(addr,0,amount,block.timestamp);
        accountStorage()._balance[addr] += amount;
    }

    function sub(address addr, uint256 amount)
        external
        isValidAddress(addr)
    {
        transaction.addTransaction(addr,0,amount,block.timestamp);
        accountStorage()._balance[addr] -= amount;
    }

    function transferBalances(address sender,address receiver)
        external
        isValidAddress(sender)
        isValidAddress(receiver)
    {
        uint256 amount = accountStorage()._balance[sender];
        accountStorage()._balance[receiver] = amount;
        accountStorage()._balance[sender] = 0;
        transaction.addTransaction(sender,0,0,block.timestamp);
        transaction.addTransaction(receiver,0,amount,block.timestamp);
        emit AccountBalanceTransfer(sender, receiver, accountStorage()._balance[receiver]);
    }

    function transfer(address sender,address receiver, uint256 amount)
        external
        isValidAddress(sender)
        isValidAddress(receiver)
    {
        accountStorage()._balance[sender] += amount;
        accountStorage()._balance[receiver] -= amount;
        transaction.addTransaction(sender,0,amount,block.timestamp);
        transaction.addTransaction(receiver,0,amount,block.timestamp);
        emit AccountTransfer(sender,receiver,amount);
    }
}