// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * This library is using Diamond Storage to hold state variables. Additionally, library functions cannot have payable methods, in essence we have gas-free state variables?
 */

library Account {
    event AccountBalanceTransfer(address sender,address receiver,uint256 amount);
    event AccountTransfer(address sender,address receiver,uint256 amount);

    /**
     * @dev Diamond storage for adding state variables in libraries
     * https://dev.to/mudgen/solidity-libraries-can-t-have-state-variables-oh-yes-they-can-3ke9
     */
    struct AccountStorage {
        mapping (address => uint256) _balance;
    }

    function accountStorage() internal pure returns (AccountStorage storage ds)
    {
        bytes32 position = keccak256("account.storage");
        assembly { ds.slot := position }
    }

    function balanceOf(address addr) internal view returns (uint256)
    {
        // @dev To reference the mapping using diamon storage
        // https://medium.com/@mudgen/new-storage-layout-for-proxy-contracts-and-diamonds-98d01d0eadb
        return accountStorage()._balance[addr];
    }

    function isSufficientBalance(address addr, uint256 value) internal view returns (bool)
    {
        return (accountStorage()._balance[addr] > value);
    }

    function setBalance(address addr, uint256 amount)
        internal
    {
        accountStorage()._balance[addr] = amount;
    }

    function getBalance(address addr) internal view returns (uint256)
    {
        return accountStorage()._balance[addr];
    }

    function add(address addr, uint256 amount)
        internal
    {
        accountStorage()._balance[addr] += amount;
    }

    function sub(address addr, uint256 amount)
        internal
    {
        accountStorage()._balance[addr] -= amount;
    }

    function transferBalances(address sender,address receiver)
        internal
    {
        accountStorage()._balance[receiver] = accountStorage()._balance[sender];
        accountStorage()._balance[sender] = 0;
        emit AccountBalanceTransfer(sender, receiver, accountStorage()._balance[receiver]);
    }

    function transfer(address sender,address receiver, uint256 amount)
        internal
    {
        accountStorage()._balance[sender] += amount;
        accountStorage()._balance[receiver] -= amount;
        emit AccountTransfer(sender,receiver,amount);
    }
}