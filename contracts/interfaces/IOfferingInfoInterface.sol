// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./IOfferingTypeInterface.sol";
import "./IERC20.sol";

interface IOfferingInfoInterface {
    struct OfferingInfo {
        IERC20          token;
        string          name;
        string          symbol;
        uint256         maxShares;
        IOfferingTypeInterface.OfferingType    offeringType;
        uint256         minOffering;
        uint256         maxOffering;
        uint256         started;            // epoch timestamp
        uint256         expiry;             // epoch timestamp, 0=no expiry
        uint256         maxAccredited;
        uint256         maxSophisticated;
        uint256         maxNonAccredited;
        uint256         lastTimeRequest;
        uint256         outstanding;
        uint256         remaining;
        string          cusip;
        string          isin;
        address         issuer;
        bool            restricted;
        bool            active;
        uint256         price; // initial share price
        uint256         bid;
        uint256         ask;
        uint256         fee; // transfer fee
        uint256         totalSupply;
        uint256         reserve;
    }    
}
