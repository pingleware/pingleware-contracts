// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

interface SocialNetworkInterface {
    function getContractOwner() external view returns (address);
}