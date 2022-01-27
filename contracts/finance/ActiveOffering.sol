// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;


library ActiveOffering {
    struct ActiveOfferingStorage {
        bool active;        
    }

    function activeOfferingStorage() internal pure returns (ActiveOfferingStorage storage ds)
    {
        bytes32 position = keccak256("activeoffering.storage");
        assembly { ds.slot := position }
    }

    function isActive()
        external
        view
        returns (bool)
    {
        return activeOfferingStorage().active;
    }

    function set(bool _active)
        external
    {
        activeOfferingStorage().active = _active;
    }

    function get()
        external
        view
        returns (bool)
    {
        return activeOfferingStorage().active;
    }

}