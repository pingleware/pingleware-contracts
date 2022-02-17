// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

// A common interface of required functions that are invoked from another contract.
// These functions must exist in the destination contract before making an invocation?

interface ExternalContractInterface {
    function getContractOwner() external  returns (address);    
}