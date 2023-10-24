// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IHouseOfRepresentatives {
    function isMember(address account) external view returns (bool);
    function introduceBill(string memory title) external;
    function getPresidentElect(string memory electionYear) external view returns (string memory);
    function getHouseCertificate(string memory electionYear) external view returns (string memory);
}