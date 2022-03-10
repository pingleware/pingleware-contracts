// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";
import "../libs/SafeMath.sol";

contract AircraftOwnership is Version, Owned {
    string public symbol;   // The aircraft serial or N-number
    string public name;     // Brand and model of aircraft
    uint256 public constant totalSupply = 1;
    uint256 public constant decimals = 0;

    mapping (address => uint256) public owners;

    event Transfer(address sender,address receiver,uint amount);

    constructor() {
        owners[msg.sender] = 100; // represents 100%
    }

    modifier isAuthorized(address wallet) {
        require(owners[wallet] > 0,"not an owner");
        _;
    }

    function transfer(address to, uint tokens) public isAuthorized(msg.sender) returns (bool success) {
        require(to != address(0), "Null address");
        require(tokens > 0, "Invalid Value"); // percentage of ownership being transferred
        require(owners[msg.sender] >= tokens,"insufficient ownership percentage for transfer");

        owners[msg.sender] = SafeMath.safeSub(owners[msg.sender], tokens);
        owners[to] = SafeMath.safeAdd(owners[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public isAuthorized(from) returns (bool success) {
        require(to != address(0), "Null address");
        require(from != address(0), "Null address");
        require(tokens > 0, "Invalid value");
        require(owners[from] >= tokens,"insufficient ownership percentage for transfer");

        owners[from] = SafeMath.safeSub(owners[from], tokens);
        owners[to] = SafeMath.safeAdd(owners[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function getOwnership() public view isAuthorized(msg.sender) returns(uint256) {
        return owners[msg.sender];
    }

}