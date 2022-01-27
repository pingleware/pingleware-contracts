// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";
import "../Owned.sol";

// Migrate to solidity https://github.com/geetotes/acme-insurance-quotes

contract Quote is Version, Owned {

    enum States {
        WELCOME,
        VEHICLE_CHOOSE,
        CAR,
        BOAT,
        BOAT_DETAIL,
        CONFIRM
    }
}