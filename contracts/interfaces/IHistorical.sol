// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IHistorical {
    struct Quote {
        uint256 timestamp;
        address token;
        uint256 volume;
        uint256 price;
    }

    function addQuote(address token,uint256 volume,uint256 price) external;
    function getHistorical(address token) external view returns (Quote[] memory);
}