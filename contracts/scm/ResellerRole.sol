// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;


// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'ResellerRole' to manage this role - add, remove, check
contract ResellerRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event ResellerAdded(address indexed account);
  event ResellerRemoved(address indexed account);

  // Define a struct 'resellers' by inheriting from 'Roles' library, struct Role
  Roles.Role private resellers;

  // In the constructor make the address that deploys this contract the 1st consumer
  constructor() {
      _addReseller(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyReseller() {
    require(isReseller(msg.sender), "You need to have the consumer role to perform this");
    _;
  }

  // Define a function 'isReseller' to check this role
  function isReseller(address account) public view returns (bool) {
    return resellers.has(account);
  }

  // Define a function 'addReseller' that adds this role
  function addReseller(address account) public onlyReseller {
    _addReseller(account);
  }

  // Define a function 'renounceReseller' to renounce this role
  function renounceReseller() public {
    _removeReseller(msg.sender);
  }

  // Define an internal function '_addReseller' to add this role, called by 'addReseller'
  function _addReseller(address account) internal {
    resellers.add(account);
    emit ResellerAdded(account);
  }

  // Define an internal function '_removeReseller' to remove this role, called by 'removeReseller'
  function _removeReseller(address account) internal {
    resellers.remove(account);
    emit ResellerRemoved(account);
  }
}