// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;




abstract contract Offering {

    enum OfferingType {
        SECTION3A11,
        RULE147,
        RULE147A,
        SECTION4A2,
        RULE504,
        RULE505,
        RULE506B,
        RULE506C,
        RULE701,
        REGAT1,
        REGAT2,
        REGS,
        S1
    }

    struct OfferingInfo {
        string          name;
        string          symbol;
        uint256         maxShares;
        OfferingType    offeringType;
        uint256         minOffering;
        uint256         maxOffering;
        uint256         started;
        uint256         expiry;
        uint256         maxAccredited;
        uint256         maxSophisticated;
        uint256         maxNonAccredited;
        uint256         lastTimeRequest;
    }


    mapping (address => OfferingInfo) private offerings;

    function setOffering(address _contract,string memory name, string memory symbol, uint256 maxShares, OfferingType offeringType)
        internal
    {
        OfferingInfo memory offering = OfferingInfo(name,symbol,maxShares,offeringType,0,0,0,0,0,0,0,0);
        offerings[_contract] = offering;
    }


    function getOffering(address _contract)
        public
        view
        returns (OfferingInfo memory)
    {
        return offerings[_contract];
    }

}