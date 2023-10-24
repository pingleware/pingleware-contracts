// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

contract UserAccount {

    mapping(address => uint256) private balances;

    constructor() {}

    function balanceOf(address addr) public view returns (uint256) {
        return balances[addr];
    }
    function isSufficientBalance(address addr, uint256 value) public view returns(bool) {
        return (balances[addr] >= value);
    }
    function setBalance(address addr, uint256 amount) public payable {
        balances[addr] = amount;
    }
    function getBalance(address addr) public view returns (uint256) {
        return balances[addr];
    }
    function add(address addr, uint256 amount) public payable {
        balances[addr] += amount;
    }
    function sub(address addr, uint256 amount) public payable {
        balances[addr] -= amount;
    }
    function transferBalances(address sender,address receiver) public payable {
        balances[receiver] += balances[sender];
        balances[sender] = 0;
    }
    function transfer(address sender,address receiver, uint256 amount) public payable {
        balances[sender] -= amount;
        balances[receiver] += amount;
    }
}