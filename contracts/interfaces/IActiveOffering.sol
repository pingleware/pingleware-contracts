// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

interface IActiveOffering {
    function set(address offering, bool status) external;
    function isActive(address offering) external view returns (bool);
}
