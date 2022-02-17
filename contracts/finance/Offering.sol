// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

contract Offering {

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

    struct OfferingStorage {
        mapping (address => OfferingInfo) offerings;
    }

    modifier isValidAddress(address addr) {
        require (addr != address(0), "zero address not permitted");
        _;
    }

    function offeringStorage()
        internal
        pure
        returns (OfferingStorage storage ds)
    {
        bytes32 position = keccak256("offering.storage");
        assembly { ds.slot := position }
    }

    function setOffering(address _contract,
                         string memory name, 
                         string memory symbol, 
                         uint256 maxShares, 
                         OfferingType offeringType
                        )
        external
        isValidAddress(_contract)
    {
        require(_contract != address(0x0),"invalid offering contract");
        OfferingInfo memory offering = OfferingInfo(name,symbol,maxShares,offeringType,0,0,0,0,0,0,0,0);
        offeringStorage().offerings[_contract] = offering;
    }

    function setMinimumOffering(address _contract, uint256 amount)
        external
        isValidAddress(_contract)
    {
        require(_contract != address(0x0),"invalid offering contract");
        offeringStorage().offerings[_contract].minOffering = amount;
    }
    function setMaximumOffering(address _contract, uint256 amount)
        external
        isValidAddress(_contract)
    {
        require(_contract != address(0x0),"invalid offering contract");
        offeringStorage().offerings[_contract].maxOffering = amount;
    }
    function setOfferingStartTime(address _contract, uint256 amount)
        external
        isValidAddress(_contract)
    {
        require(_contract != address(0x0),"invalid offering contract");
        offeringStorage().offerings[_contract].started = amount;
    }
    function setOfferingEndTime(address _contract, uint256 amount)
        external
        isValidAddress(_contract)
    {
        require(_contract != address(0x0),"invalid offering contract");
        offeringStorage().offerings[_contract].expiry = amount;
    }
    function setMaximumAccreditedInvestors(address _contract, uint256 amount)
        external
        isValidAddress(_contract)
    {
        require(_contract != address(0x0),"invalid offering contract");
        offeringStorage().offerings[_contract].maxAccredited = amount;
    }
    function setMaximumSopisticatedInvestors(address _contract, uint256 amount)
        external
        isValidAddress(_contract)
    {
        require(_contract != address(0x0),"invalid offering contract");
        offeringStorage().offerings[_contract].maxSophisticated = amount;
    }
    function setMaximumNonAccreditedInvestors(address _contract, uint256 amount)
        external
        isValidAddress(_contract)
    {
        require(_contract != address(0x0),"invalid offering contract");
        offeringStorage().offerings[_contract].maxNonAccredited = amount;
    }
    function getLastTimeRequest(address _contract)
        external
        view
        isValidAddress(_contract)
        returns (uint256)
    {
        require(_contract != address(0x0),"invalid offering contract");
        return offeringStorage().offerings[_contract].lastTimeRequest;
    }


    function getOffering(address _contract)
        external
        view
        returns (OfferingInfo memory)
    {
        require(_contract != address(0x0),"invalid offering contract");
        return offeringStorage().offerings[_contract];
    }

}