// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IAccessControl {
    function getOwner() external view returns (address);
}