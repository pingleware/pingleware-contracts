// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/**
 * BestBooks Accounting Application Framework is a registered trademark &trade; of PRESSPAGE ENTERTAINMENT INC.
 */

import "../../interfaces/IBestBooks.sol";
import "../../interfaces/IMemberPool.sol";

contract BestBooks is IBestBooks {
    mapping(string => int256) public balances;
    mapping(uint256 => Entry) public ledger;
    mapping(string => Account) public chartOfAccounts;

    uint256 public ledgerCount;

    function addEntry(
        uint256 timestamp,
        string memory debitAccount,
        string memory creditAccount,
        string memory description,
        int256 debitAmount,
        int256 creditAmount
    ) override external {
        
        balances[debitAccount] += debitAmount;
        balances[creditAccount] += creditAmount;

        Entry memory entry = Entry(
            timestamp,
            debitAccount,
            creditAccount,
            description,
            debitAmount,
            creditAmount
        );
        ledger[ledgerCount] = entry;
        ledgerCount++;

        emit EntryAdded(timestamp, debitAccount, creditAccount, description, debitAmount, creditAmount);
    }

    function getBalance(string memory account) override external view  returns (int256) {
        return balances[account];
    }

    function getLedgerEntry(uint256 index) override external view  returns (
        uint256,
        string memory,
        string memory,
        string memory,
        int256,
        int256
    ) {
        require(index < ledgerCount, "Invalid ledger index");
        Entry memory entry = ledger[index];
        return (
            entry.timestamp,
            entry.debitAccount,
            entry.creditAccount,
            entry.description,
            entry.debitAmount,
            entry.creditAmount
        );
    }

    function getLedgerEntryByRange(uint256 startingTimestamp,uint256 endingTimestamp) external payable  returns(Entry[] memory) {
        Entry[] memory entries;
        uint256 index=0;

        for (uint256 i=0; i<ledgerCount; i++) {
            if (ledger[i].timestamp >= startingTimestamp && ledger[i].timestamp < endingTimestamp) {
                entries[index++] = ledger[i];
            }
        }
        return entries;
    }
        
    modifier accountExists(string memory accountName) {
        require(bytes(chartOfAccounts[accountName].name).length > 0, "Account does not exist");
        _;
    }
    
    function createAccount(string memory accountName, string memory category) override external {
        require(bytes(accountName).length > 0, "Account name is required");
        require(bytes(category).length > 0, "Account category is required");

        if (bytes(chartOfAccounts[accountName].name).length == 0) {
            Account memory account = Account(accountName, category);
            chartOfAccounts[accountName] = account;
            emit AccountCreated(accountName, category);
        }
    }
    
    function updateAccount(string memory accountName, string memory newCategory) override external accountExists(accountName) {
        require(bytes(newCategory).length > 0, "New account category is required");
        
        Account memory account = chartOfAccounts[accountName];
        account.category = newCategory;
        chartOfAccounts[accountName] = account;

        emit AccountUpdated(accountName, newCategory);
    }
    
    function deleteAccount(string memory accountName) override external  accountExists(accountName) {
        delete chartOfAccounts[accountName];
        emit AccountDeleted(accountName);
    }
    
    function getAccount(string memory accountName) override external view  returns (string memory, string memory) {
        Account memory account = chartOfAccounts[accountName];
        return (account.name, account.category);
    }
}
