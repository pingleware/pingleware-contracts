// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../../interfaces/ITokenManager.sol";
import "./AccessControl.sol";

contract TokenManager is ITokenManager, AccessControl {

    mapping(string => TOKEN) private tokenContracts;


    // Add functions for token management here
    function assignToken(address tokenAddress, address issuer, string calldata name, string calldata symbol, uint256 totalSupply, string calldata regulation) external  {
        require(tokenContracts[symbol].tokenAddress == address(0), "Token already exists");

        tokenContracts[symbol] = TOKEN(name,symbol,tokenAddress,regulation,true);
 
        emit AssignedOffering(issuer,name,symbol,totalSupply);
    }
    function isTokenActive(string calldata symbol) external view returns (bool) {
        return tokenContracts[symbol].active;
    }
    function updateTokenName(string calldata symbol,string calldata name)  external  {
        require(tokenContracts[symbol].tokenAddress != address(0x0),"token not found for symbol");
        string memory oldName = tokenContracts[symbol].name;
        tokenContracts[symbol].name = name;

        emit UpdatedListingName(oldName,name);
    }
    function updateTokenAddress(string calldata symbol,address tokenAddress)  external  {
        require(tokenContracts[symbol].tokenAddress != address(0x0),"token not found for symbol");
        address oldToken = tokenContracts[symbol].tokenAddress;
        tokenContracts[symbol].tokenAddress = tokenAddress;

        emit UpdatedListingAddress(oldToken,tokenAddress);
    }
    function updateTokenOfferingType(string calldata symbol,string calldata regulation)  external  {
        require(tokenContracts[symbol].tokenAddress != address(0x0),"token not found for symbol");
        string memory oldRegulation = tokenContracts[symbol].regulation;
        tokenContracts[symbol].regulation = regulation;

        emit UpdatedListingOfferingType(oldRegulation,regulation);
    }
    function removeToken(string calldata symbol)  external  {
        require(tokenContracts[symbol].tokenAddress != address(0x0),"token not found for symbol");
        tokenContracts[symbol].active = false;
        delete tokenContracts[symbol];
        emit DelistedToken(symbol);
    }
    function getToken(string calldata symbol)  external view  returns (address) {
        require(tokenContracts[symbol].tokenAddress != address(0x0),"token not found for symbol");
        return tokenContracts[symbol].tokenAddress;
    }
    function getTokenRegulation(string calldata symbol)  external view  returns (string memory) {
        require(tokenContracts[symbol].tokenAddress != address(0x0),"token not found for symbol");
        return tokenContracts[symbol].regulation;
    }

}
