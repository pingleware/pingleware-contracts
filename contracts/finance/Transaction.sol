// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;


library Transaction {
    uint constant public year = 52 weeks;

    struct TransactionItem {
        address addr;
        uint256 shares;
        uint256 amount;
        uint256 time;
    }

    struct TransactionStorage {
        mapping(address => TransactionItem[]) transactions;
        TransactionItem[] _transactions;
    }

    function transactionStorage()
        internal
        pure
        returns (TransactionStorage storage ds)
    {
        bytes32 position = keccak256("transaction.storage");
        assembly { ds.slot := position }
    }
    


    function isHoldingPeriodOver(address addr)
        external
        view
        returns (bool)
    {
        bool over = false;
        for (uint i = 0; i < transactionStorage().transactions[addr].length; i++) {
            if (transactionStorage().transactions[addr][i].time > (transactionStorage().transactions[addr][i].time + year)) {
                over = true;
            }
        }
        return over;
    }

    function getTransactions()
        external
        view
        returns (TransactionItem[] memory)
    {
        return transactionStorage()._transactions;
    }

    function addTransaction(address _to,uint256 _shares,uint256 _amount,uint256 _epoch)
        external
        returns (uint256)
    {
        //transactionStorage().transactions[_to] = TransactionItem(_to, _shares, _amount, _epoch);
        transactionStorage()._transactions.push(TransactionItem(_to, _shares, _amount, _epoch));
        return transactionStorage()._transactions.length;
    }
}
