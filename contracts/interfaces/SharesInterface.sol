// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;


interface SharesInterface {
    function getClass(address offering) external view returns (string memory);
    function setClass(address offering,string memory _class) external;
    function getShares(address offering) external view returns (uint256);
    function getMaxPPU(address offering) external view returns (uint256);
    function getMaxAggregate(address offering) external view returns (uint256);
    function getFee(address offering) external view returns (uint256);
    function getTotalSupply(address offering) external view returns (uint256);
    function addTotalSupply(address offering, uint256 amount) external;
    function isPriceBelowParValue(address offering, uint amount) external view returns (bool);
    function getTotalAuthorized(address offering) external view returns (uint256);
    function getOutstanding(address offering) external view returns (uint256);
    function addOutstanding(address offering, uint256 amount) external;
    function subOutstanding(address offering, uint256 amount) external;
    function isRestrictedSecurity(address offering) external view returns (bool);
    function assignCUSIP(address offering, string memory cusip) external;
    function saveCertificate(address offering,address investor, bytes32 image) external;
    function setParValue(address offering, uint256 value) external;
    function getParValue(address offering) external view returns (uint256);
    function setRestricted(address offering, bool value) external;
}