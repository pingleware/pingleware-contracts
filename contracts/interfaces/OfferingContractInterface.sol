// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

interface OfferingContractInterface {
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

    function getOwner() external view returns (address);
    function setOffering(address _contract,string memory name,string memory symbol,uint256 maxShares,OfferingType offeringType) external;
    function setMinimumOffering(address _contract, uint256 amount) external;
    function setMaximumOffering(address _contract, uint256 amount) external;
    function setOfferingStartTime(address _contract, uint256 amount) external;
    function setOfferingEndTime(address _contract, uint256 amount) external;
    function setMaximumAccreditedInvestors(address _contract, uint256 amount) external;
    function setMaximumSopisticatedInvestors(address _contract, uint256 amount) external;
    function setMaximumNonAccreditedInvestors(address _contract, uint256 amount) external;
    function getLastTimeRequest(address _contract) external view;
    function getOffering(address _contract) external view returns (OfferingInfo memory);
}
