// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Frozen.sol";
import "../libs/SafeMath.sol";

contract AircraftOwnership is Version, Frozen {
    string public symbol;   // The aircraft serial or N-number
    string public name;     // Brand and model of aircraft
    uint256 public constant totalSupply = 1;
    uint256 public constant decimals = 0;

    mapping (address => uint256) public ownership;
    mapping (address => bool) public owners;
    address[] public _owners;

    event Transfer(address sender,address receiver,uint amount);

    constructor(string memory aircraftBrand,string memory aircraftSerial) {
        symbol = aircraftSerial;
        name = aircraftBrand;
        ownership[msg.sender] = 100; // represents 100%
        _owners.push(msg.sender);
        owners[msg.sender] = true;
    }

    modifier isAuthorized(address wallet) {
        require(owners[wallet],"not an owner");
        _;
    }

    function getAircraftBrand() external view returns (string memory) {
        return name;
    }

    function getAircraftSerialNo() external view returns (string memory) {
        return symbol;
    }

    function transfer(address to, uint tokens) public isAuthorized(msg.sender) returns (bool success) {
        require(to != address(0), "Null address");
        require(tokens > 0, "Invalid Value"); // percentage of ownership being transferred
        require(ownership[msg.sender] >= tokens,"insufficient ownership percentage for transfer");

        ownership[msg.sender] = SafeMath.safeSub(ownership[msg.sender], tokens);
        ownership[to] = SafeMath.safeAdd(ownership[to], tokens);
        _owners.push(to);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public isAuthorized(from) returns (bool success) {
        require(to != address(0), "Null address");
        require(from != address(0), "Null address");
        require(tokens > 0, "Invalid value");
        require(ownership[from] >= tokens,"insufficient ownership percentage for transfer");

        ownership[from] = SafeMath.safeSub(ownership[from], tokens);
        ownership[to] = SafeMath.safeAdd(ownership[to], tokens);
        _owners.push(to);
        emit Transfer(from, to, tokens);
        return true;
    }

    function getOwnership(address wallet) external view returns(uint256) {
        return ownership[wallet];
    }

    function getOwners() external view returns (address[] memory) {
        return _owners;
    }
}