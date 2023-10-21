// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/**
 * BestBooks Accounting Application Framework is a registered trademark &trade; of PRESSPAGE ENTERTAINMENT INC.
 */

interface IBestBooks {
    struct Entry {
        uint256 timestamp;
        string debitAccount;
        string creditAccount;
        string description;
        int256 debitAmount;
        int256 creditAmount;
    }
        
    // Traditional Chart of Accounts
    struct Account {
        string name;
        string category; // is the account type: Asset, Liability, Equity, Expense, Revenue, etc.
    }


    event EntryAdded(uint256 timestamp,string debitAccount,string creditAccount,string description,int256 debitAmount,int256 creditAmount);
    event AccountCreated(string accountName, string category);
    event AccountUpdated(string accountName, string category);
    event AccountDeleted(string accountName);

    function addEntry(uint256 timestamp,string memory debitAccount,string memory creditAccount,string memory description,int256 debitAmount,int256 creditAmount)  external;
    function getBalance(string memory account)  external view returns (int256);
    function getLedgerEntry(uint256 index)  external view returns (uint256,string memory,string memory,string memory,int256,int256);
    function createAccount(string memory accountName, string memory category)  external;
    function updateAccount(string memory accountName, string memory newCategory)  external;
    function deleteAccount(string memory accountName)  external;
    function getAccount(string memory accountName)  external view returns (string memory, string memory);
    function getLedgerEntryByRange(uint256 startingTimestamp,uint256 endingTimestamp) external payable returns(Entry[] memory);
}