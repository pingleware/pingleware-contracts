// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IUSSenate {
     function isSenator(address account) external view returns (bool);
     function introduceBill(string memory title) external;
     function getSenateCertificate(string memory electionYear) external view returns (string memory);
}