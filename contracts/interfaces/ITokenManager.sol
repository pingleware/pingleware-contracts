// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface ITokenManager {
    struct TOKEN {
        string name;
        string symbol;
        address tokenAddress;
        string regulation;
        bool active;
    }

    event AssignedOffering(address,string,string,uint256);
    event UpdatedListingName(string,string);
    event UpdatedListingAddress(address,address);
    event UpdatedListingOfferingType(string,string);
    event DelistedToken(string);

    function assignToken(address tokenAddress, address issuer, string calldata name, string calldata symbol, uint256 totalSupply, string calldata regulation) external;
    function getToken(string calldata symbol)  external view  returns (address);
    function isTokenActive(string calldata symbol) external view returns (bool);
    function updateTokenName(string calldata symbol,string calldata name)  external;
    function updateTokenAddress(string calldata symbol,address tokenAddress)  external;
    function updateTokenOfferingType(string calldata symbol,string calldata regulation)  external;
    function removeToken(string calldata symbol)  external;
    function getTokenRegulation(string calldata symbol)  external view  returns (string memory);
}