// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../../interfaces/IToken.sol";

contract DebtToken is IToken {
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint256 public _totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    mapping(address => uint256) public approvals;

    address public _owner;

    constructor() {
        _owner = msg.sender;
    }
    function name() external view returns (string memory) {
        return _name;
    }
    function symbol() external view returns (string memory) {
        return _symbol;
    }
    function decimals() external view returns (uint8) {
        return _decimals;
    }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function setTotalSupply(uint256 amount) external {
        _totalSupply = amount;
    }
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
    function transfer(address to, uint256 amount) external returns (bool) {
        if (balances[msg.sender] < amount) return false;
        balances[msg.sender] -= amount;
        balances[to] += amount;
        return true;
    }
    function allowance(address owner, address spender) external view returns (uint256) {
        require(owner == _owner,"not the owner");
        return allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        approvals[spender] = amount;
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if (balances[from] < amount) return false;
        balances[from] -= amount;
        balances[to] += amount;
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        allowances[_owner][spender] += addedValue;
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        allowances[_owner][spender] -= subtractedValue;
        return true;
    }

}