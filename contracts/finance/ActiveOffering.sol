// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../interfaces/OfferingContractInterface.sol";

contract ActiveOffering {
    struct ActiveOfferingStorage {
        mapping(address => bool) active;
    }

    OfferingContractInterface private Offering;


    function activeOfferingStorage() internal pure returns (ActiveOfferingStorage storage ds)
    {
        bytes32 position = keccak256("activeoffering.storage");
        assembly { ds.slot := position }
    }

    function isActive(address offering)
        external
        view
        returns (bool)
    {
        require(offering != address(0x0),"invalid offering contract");
        return activeOfferingStorage().active[offering];
    }

    function set(address offering, bool _active)
        external
    {
        require(offering != address(0x0),"invalid offering contract");
        Offering = OfferingContractInterface(offering);
        require(msg.sender != Offering.getOwner(),"unauthorized access");
        activeOfferingStorage().active[offering] = _active;
    }

    function get(address offering)
        external
        view
        returns (bool)
    {
        require(offering != address(0x0),"invalid offering contract");
        return activeOfferingStorage().active[offering];
    }

}